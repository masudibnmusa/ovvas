import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../domain/dates.dart';
import '../domain/habit.dart';
import '../domain/stats.dart';
import '../domain/widget_config.dart';
import 'local/database.dart';
import 'local/records.dart';
import 'sync/cloud_sync.dart';

/// App data. The UI talks only to this class.
///
/// Screens read from memory, so reads stay instant and synchronous. Every
/// change is also written to the local database [db] (in order, in the
/// background) and handed to [cloud] for backup. Without a database the store
/// works in memory only, which tests use.
class HabitStore extends ChangeNotifier {
  HabitStore({DateTime Function()? clock, this._db, CloudSync? cloud})
      : _clock = clock ?? DateTime.now,
        cloud = cloud ?? FakeCloudSync(clock: clock) {
    this.cloud
      ..addListener(notifyListeners)
      ..onRemoteChange = reload;
  }

  final DateTime Function() _clock;
  final AppDatabase? _db;
  final CloudSync cloud;
  final List<Habit> _habits = [];
  final Map<String, Map<DateTime, DayEntry>> _entries = {};
  final List<WidgetConfig> _widgets = [];

  /// Database writes run one after another in this chain.
  Future<void> _writes = Future.value();

  /// Bumped on every change, so [reload] can tell if memory changed under it.
  int _version = 0;
  int _lastStamp = 0;

  // TODO: set from the subscription service (step 3).
  bool isPlus = false;

  static const freeWidgetLimit = 3;

  DateTime now() => _clock();
  DateTime get today => dateOnly(_clock());
  Stats get stats => Stats(entry, today: today);

  // ---- Habits ----

  List<Habit> get habits => List.unmodifiable(_habits.where((h) => !h.archived));
  List<Habit> get archivedHabits => List.unmodifiable(_habits.where((h) => h.archived));

  Habit? habitById(String id) {
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  List<Habit> habitsOn(DateTime day) => habits.where((h) => h.isScheduledOn(day)).toList();

  String newId() => newUuid();

  void addHabit(Habit h) {
    _habits.add(h);
    _saveHabit(h);
    _changed();
  }

  void updateHabit(Habit h) {
    final i = _habits.indexWhere((x) => x.id == h.id);
    if (i < 0) return;
    _habits[i] = h;
    _saveHabit(h);
    _changed();
  }

  void _saveHabit(Habit h) {
    final stamp = _stamp();
    _persist((db) => db.into(db.habits).insertOnConflictUpdate(habitToRow(h, stamp)));
  }

  void setArchived(String id, bool archived) {
    final h = habitById(id);
    if (h != null) updateHabit(h.copyWith(archived: archived));
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _entries.remove(id);
    final stamp = _stamp();
    _persist((db) async {
      // Mark the habit deleted so other phones learn about it. Its check-ins
      // are removed here, and by the server for the cloud copy.
      await (db.update(db.habits)..where((t) => t.id.equals(id)))
          .write(HabitsCompanion(deleted: const Value(true), dirty: const Value(true), updatedAt: Value(stamp)));
      await (db.delete(db.entries)..where((t) => t.habitId.equals(id))).go();
    });
    for (var i = 0; i < _widgets.length; i++) {
      final w = _widgets[i];
      if (w.habitIds.contains(id)) {
        _widgets[i] = w.copyWith(habitIds: w.habitIds.where((x) => x != id).toList());
        _saveWidgetAt(i);
      }
    }
    _changed();
  }

  // ---- Check-ins ----

  DayEntry? entry(String habitId, DateTime day) => _entries[habitId]?[dateOnly(day)];

  /// One-tap check. Yes/No habits flip between done and not done. Count and
  /// Time habits add one step, or step back below the target when already
  /// done. Returns true when this tap completed the habit.
  bool toggle(Habit h, DateTime day) {
    final e = entry(h.id, day) ?? const DayEntry();
    final wasDone = !e.skipped && e.value >= h.target;
    final int next;
    if (h.goalType == GoalType.yesNo) {
      next = wasDone ? 0 : h.target;
    } else {
      next = wasDone ? math.max(0, h.target - h.step) : e.value + h.step;
    }
    _put(h.id, day, e.copyWith(value: next, skipped: false));
    return !wasDone && next >= h.target;
  }

  void setValue(Habit h, DateTime day, int value) {
    final e = entry(h.id, day) ?? const DayEntry();
    _put(h.id, day, e.copyWith(value: math.max(0, value), skipped: false));
  }

  void setSkipped(Habit h, DateTime day, bool skipped) {
    final e = entry(h.id, day) ?? const DayEntry();
    _put(h.id, day, e.copyWith(skipped: skipped, value: skipped ? 0 : e.value));
  }

  void setNote(Habit h, DateTime day, String note) {
    final e = entry(h.id, day) ?? const DayEntry();
    _put(h.id, day, e.copyWith(note: note.trim()));
  }

  /// Day notes for a habit, newest first.
  List<(DateTime, String)> notesFor(String habitId) {
    final m = _entries[habitId];
    if (m == null) return const [];
    return [
      for (final e in m.entries)
        if (e.value.note.isNotEmpty) (e.key, e.value.note),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
  }

  void _put(String id, DateTime day, DayEntry e) {
    final m = _entries.putIfAbsent(id, () => {});
    final d = dateOnly(day);
    if (e.isEmpty) {
      m.remove(d);
    } else {
      m[d] = e;
    }
    final stamp = _stamp();
    _persist((db) => db.into(db.entries).insertOnConflictUpdate(entryToRow(id, d, e, stamp)));
    _changed();
  }

  // ---- Widgets ----

  List<WidgetConfig> get widgets => List.unmodifiable(_widgets);
  bool get canAddWidget => isPlus || _widgets.length < freeWidgetLimit;
  String newWidgetId() => newUuid();

  void saveWidget(WidgetConfig w) {
    var i = _widgets.indexWhere((x) => x.id == w.id);
    if (i < 0) {
      _widgets.add(w);
      i = _widgets.length - 1;
    } else {
      _widgets[i] = w;
    }
    _saveWidgetAt(i);
    _changed();
  }

  void _saveWidgetAt(int position) {
    final w = _widgets[position];
    final stamp = _stamp();
    _persist((db) => db.into(db.widgetConfigs).insertOnConflictUpdate(widgetToRow(w, position, stamp)));
  }

  void removeWidget(String id) {
    _widgets.removeWhere((w) => w.id == id);
    final stamp = _stamp();
    _persist((db) => (db.update(db.widgetConfigs)..where((t) => t.id.equals(id)))
        .write(WidgetConfigsCompanion(deleted: const Value(true), dirty: const Value(true), updatedAt: Value(stamp))));
    _changed();
  }

  // ---- Account and backup ----

  bool get signedIn => cloud.signedIn;
  String get accountEmail => cloud.accountEmail;
  DateTime? get lastBackup => cloud.lastBackup;

  Future<void> signIn() => cloud.signIn();

  /// Local data stays; backups stop until signing in again.
  Future<void> signOut() => cloud.signOut();

  Future<bool> backUpNow() async {
    await flush();
    return cloud.syncNow();
  }

  // ---- Persistence ----

  /// Replaces memory with what is in the database. Called at startup and
  /// after a sync brought in changes from another phone.
  Future<void> reload() async {
    final db = _db;
    if (db == null) return;
    while (true) {
      final version = _version;
      await flush();
      final habitRows = await (db.select(db.habits)..where((t) => t.deleted.not())).get();
      final entryRows = await (db.select(db.entries)..where((t) => t.deleted.not())).get();
      final widgetRows = await (db.select(db.widgetConfigs)
            ..where((t) => t.deleted.not())
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .get();
      // The user changed something while we were reading; read again.
      if (version != _version) continue;

      _habits
        ..clear()
        ..addAll(habitRows.map(habitFromRow));
      final live = {for (final h in _habits) h.id};
      _entries.clear();
      for (final r in entryRows) {
        if (!live.contains(r.habitId)) continue;
        _entries.putIfAbsent(r.habitId, () => {})[parseDay(r.day)] = entryFromRow(r);
      }
      _widgets
        ..clear()
        ..addAll(widgetRows.map(widgetFromRow));
      notifyListeners();
      return;
    }
  }

  /// Waits until every change so far is saved to the database.
  Future<void> flush() => _writes;

  void _persist(Future<void> Function(AppDatabase db) write) {
    final db = _db;
    if (db == null) return;
    _writes = _writes.then((_) => write(db)).catchError((Object e, StackTrace s) {
      debugPrint('Saving failed: $e\n$s');
    });
  }

  /// Change time for sync. Always increases, even for changes in the same
  /// millisecond, so a newer edit is never mistaken for an older one.
  int _stamp() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _lastStamp = math.max(now, _lastStamp + 1);
  }

  void _changed() {
    _version++;
    cloud.requestSync();
    notifyListeners();
  }

  @override
  void dispose() {
    cloud.removeListener(notifyListeners);
    super.dispose();
  }
}
