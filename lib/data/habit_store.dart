import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/dates.dart';
import '../domain/habit.dart';
import '../domain/stats.dart';
import '../domain/widget_config.dart';

/// In-memory app data. The UI talks only to this class, so a local database
/// and cloud sync can replace the storage later without touching screens.
class HabitStore extends ChangeNotifier {
  HabitStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<Habit> _habits = [];
  final Map<String, Map<DateTime, DayEntry>> _entries = {};
  final List<WidgetConfig> _widgets = [];
  int _nextId = 1;

  // Account and backup are mocked until the backend exists.
  bool signedIn = true;
  String accountEmail = 'nabila@example.com';
  DateTime? lastBackup;
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

  String newId() => 'h${_nextId++}';

  void addHabit(Habit h) {
    _habits.add(h);
    _changed();
  }

  void updateHabit(Habit h) {
    final i = _habits.indexWhere((x) => x.id == h.id);
    if (i < 0) return;
    _habits[i] = h;
    _changed();
  }

  void setArchived(String id, bool archived) {
    final h = habitById(id);
    if (h != null) updateHabit(h.copyWith(archived: archived));
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _entries.remove(id);
    for (var i = 0; i < _widgets.length; i++) {
      final w = _widgets[i];
      if (w.habitIds.contains(id)) {
        _widgets[i] = w.copyWith(habitIds: w.habitIds.where((x) => x != id).toList());
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
    _changed();
  }

  // ---- Widgets ----

  List<WidgetConfig> get widgets => List.unmodifiable(_widgets);
  bool get canAddWidget => isPlus || _widgets.length < freeWidgetLimit;
  String newWidgetId() => 'w${_nextId++}';

  void saveWidget(WidgetConfig w) {
    final i = _widgets.indexWhere((x) => x.id == w.id);
    if (i < 0) {
      _widgets.add(w);
    } else {
      _widgets[i] = w;
    }
    _changed();
  }

  void removeWidget(String id) {
    _widgets.removeWhere((w) => w.id == id);
    _changed();
  }

  // ---- Backup (mock) ----

  /// Mock sign-in. Data stays on the phone either way.
  void signIn() {
    signedIn = true;
    lastBackup = _clock();
    notifyListeners();
  }

  /// Mock sign-out. Local data stays; backups stop until signing in again.
  void signOut() {
    signedIn = false;
    lastBackup = null;
    notifyListeners();
  }

  void backUpNow() {
    lastBackup = _clock();
    notifyListeners();
  }

  void _changed() {
    if (signedIn) lastBackup = _clock();
    notifyListeners();
  }
}
