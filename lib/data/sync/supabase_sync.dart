import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';
import '../local/records.dart';
import 'cloud_sync.dart';

/// Two-way sync between the local database and Supabase.
///
/// - Push: rows marked dirty are upserted. The server keeps whichever copy has
///   the newer `updated_at` (see the SQL migration).
/// - Pull: rows the server stored since the last pull are fetched, and each
///   replaces the local copy if it is newer.
class SupabaseCloudSync extends CloudSync {
  SupabaseCloudSync(this._db, {required this.redirectUrl});

  final AppDatabase _db;

  /// Where the Google sign-in page sends the user back to. Must match the
  /// deep link set up for Android and iOS, and the Supabase redirect list.
  final String redirectUrl;

  static const _pageSize = 1000;
  static const _lastBackupKey = 'sync.lastBackup';

  /// Re-reads a short window before the bookmark, so rows saved by
  /// overlapping server transactions are never missed. Re-reading is harmless.
  static const _overlap = Duration(seconds: 30);

  SupabaseClient get _client => Supabase.instance.client;
  GoTrueClient get _auth => _client.auth;

  StreamSubscription<AuthState>? _authSub;
  AppLifecycleListener? _lifecycle;
  Timer? _debounce;
  DateTime? _lastBackup;
  Future<bool>? _current;
  bool _again = false;

  @override
  bool get signedIn => _auth.currentUser != null;
  @override
  String get accountEmail => _auth.currentUser?.email ?? '';
  @override
  DateTime? get lastBackup => _lastBackup;

  Future<void> init() async {
    final saved = await _db.readValue(_lastBackupKey);
    _lastBackup = saved == null ? null : DateTime.tryParse(saved)?.toLocal();
    _authSub = _auth.onAuthStateChange.listen((s) {
      switch (s.event) {
        case AuthChangeEvent.signedIn:
          notifyListeners();
          requestSync(immediately: true);
        case AuthChangeEvent.signedOut:
          notifyListeners();
        default:
          break;
      }
    });
    _lifecycle = AppLifecycleListener(onResume: () => requestSync(immediately: true));
    if (signedIn) requestSync(immediately: true);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _lifecycle?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Future<void> signIn() async {
    await _auth.signInWithOAuth(OAuthProvider.google, redirectTo: redirectUrl);
  }

  @override
  Future<void> signOut() async {
    _debounce?.cancel();
    await _auth.signOut();
    // Local data stays. Mark it all for upload so the next account that
    // signs in on this phone gets a full copy.
    await _db.markAllDirty();
    for (final t in _tables) {
      await _db.writeValue(_cursorKey(t), null);
    }
    _lastBackup = null;
    await _db.writeValue(_lastBackupKey, null);
    notifyListeners();
  }

  @override
  void requestSync({bool immediately = false}) {
    if (!signedIn) return;
    _debounce?.cancel();
    _debounce = Timer(immediately ? Duration.zero : const Duration(seconds: 2), syncNow);
  }

  @override
  Future<bool> syncNow() {
    if (_auth.currentUser == null) return Future.value(false);
    final running = _current;
    if (running != null) {
      // Run once more after the current pass, to include the latest changes.
      _again = true;
      return running;
    }
    return _current = _run().whenComplete(() => _current = null);
  }

  Future<bool> _run() async {
    var ok = true;
    try {
      do {
        _again = false;
        final user = _auth.currentUser;
        if (user == null) return false;
        await _pushAll(user.id);
        if (await _pullAll()) await onRemoteChange?.call();
      } while (_again);
      _lastBackup = DateTime.now();
      await _db.writeValue(_lastBackupKey, _lastBackup!.toUtc().toIso8601String());
    } catch (e, s) {
      ok = false;
      debugPrint('Sync failed: $e\n$s');
    }
    notifyListeners();
    return ok;
  }

  // ---- Push ----

  Future<void> _pushAll(String userId) async {
    final habits = await (_db.select(_db.habits)..where((t) => t.dirty)).get();
    await _upsert('habits', 'user_id,id', [for (final r in habits) habitRowToCloud(r, userId)]);
    await _db.batch((b) {
      for (final r in habits) {
        b.update(_db.habits, const HabitsCompanion(dirty: Value(false)),
            where: (t) => t.id.equals(r.id) & t.updatedAt.equals(r.updatedAt));
      }
    });

    final entries = await (_db.select(_db.entries)..where((t) => t.dirty)).get();
    await _upsert('entries', 'user_id,habit_id,day', [for (final r in entries) entryRowToCloud(r, userId)]);
    await _db.batch((b) {
      for (final r in entries) {
        b.update(_db.entries, const EntriesCompanion(dirty: Value(false)),
            where: (t) => t.habitId.equals(r.habitId) & t.day.equals(r.day) & t.updatedAt.equals(r.updatedAt));
      }
    });

    final widgets = await (_db.select(_db.widgetConfigs)..where((t) => t.dirty)).get();
    await _upsert('widget_configs', 'user_id,id', [for (final r in widgets) widgetRowToCloud(r, userId)]);
    await _db.batch((b) {
      for (final r in widgets) {
        b.update(_db.widgetConfigs, const WidgetConfigsCompanion(dirty: Value(false)),
            where: (t) => t.id.equals(r.id) & t.updatedAt.equals(r.updatedAt));
      }
    });
  }

  Future<void> _upsert(String table, String onConflict, List<Map<String, Object?>> rows) async {
    for (var i = 0; i < rows.length; i += 500) {
      final chunk = rows.sublist(i, (i + 500).clamp(0, rows.length));
      await _client.from(table).upsert(chunk, onConflict: onConflict);
    }
  }

  // ---- Pull ----

  static const _tables = ['habits', 'entries', 'widget_configs'];

  String _cursorKey(String table) => 'sync.cursor.$table';

  /// Returns true if anything in the local database changed.
  Future<bool> _pullAll() async {
    var changed = false;
    changed |= await _pull('habits', _mergeHabits);
    changed |= await _pull('entries', _mergeEntries);
    changed |= await _pull('widget_configs', _mergeWidgets);
    return changed;
  }

  Future<bool> _pull(String table, Future<bool> Function(List<Map<String, dynamic>>) merge) async {
    final cursor = await _db.readValue(_cursorKey(table));
    final since = cursor == null ? null : DateTime.parse(cursor).subtract(_overlap).toUtc().toIso8601String();
    var changed = false;
    var newest = cursor;
    for (var offset = 0;; offset += _pageSize) {
      var query = _client.from(table).select();
      if (since != null) query = query.gt('synced_at', since);
      final rows = await query.order('synced_at').range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;
      changed |= await merge(rows);
      newest = rows.last['synced_at'] as String;
      if (rows.length < _pageSize) break;
    }
    if (newest != cursor) await _db.writeValue(_cursorKey(table), newest);
    return changed;
  }

  Future<bool> _mergeHabits(List<Map<String, dynamic>> rows) => _db.transaction(() async {
        final remote = rows.map(habitRowFromCloud).toList();
        final local = {
          for (final r in await (_db.select(_db.habits)..where((t) => t.id.isIn(remote.map((r) => r.id)))).get())
            r.id: r,
        };
        var changed = false;
        for (final r in remote) {
          final l = local[r.id];
          if (l != null && l.updatedAt >= r.updatedAt) continue;
          await _db.into(_db.habits).insertOnConflictUpdate(r);
          if (r.deleted) await (_db.delete(_db.entries)..where((t) => t.habitId.equals(r.id))).go();
          changed = true;
        }
        return changed;
      });

  Future<bool> _mergeEntries(List<Map<String, dynamic>> rows) => _db.transaction(() async {
        final remote = rows.map(entryRowFromCloud).toList();
        final habitIds = remote.map((r) => r.habitId).toSet();
        final days = remote.map((r) => r.day).toSet();
        final local = {
          for (final r in await (_db.select(_db.entries)
                ..where((t) => t.habitId.isIn(habitIds) & t.day.isIn(days)))
              .get())
            '${r.habitId}|${r.day}': r,
        };
        var changed = false;
        for (final r in remote) {
          final l = local['${r.habitId}|${r.day}'];
          if (l != null && l.updatedAt >= r.updatedAt) continue;
          await _db.into(_db.entries).insertOnConflictUpdate(r);
          changed = true;
        }
        return changed;
      });

  Future<bool> _mergeWidgets(List<Map<String, dynamic>> rows) => _db.transaction(() async {
        final remote = rows.map(widgetRowFromCloud).toList();
        final local = {
          for (final r in await (_db.select(_db.widgetConfigs)..where((t) => t.id.isIn(remote.map((r) => r.id)))).get())
            r.id: r,
        };
        var changed = false;
        for (final r in remote) {
          final l = local[r.id];
          if (l != null && l.updatedAt >= r.updatedAt) continue;
          await _db.into(_db.widgetConfigs).insertOnConflictUpdate(r);
          changed = true;
        }
        return changed;
      });
}
