import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// Every synced table has the same three bookkeeping columns:
// - updatedAt: when the row last changed (ms since epoch, UTC). On sync the
//   newer edit wins.
// - deleted: rows are marked deleted instead of removed, so the deletion can
//   reach the cloud and other phones.
// - dirty: changed on this phone and not uploaded yet.

@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconIndex => integer()();
  IntColumn get colorIndex => integer()();
  TextColumn get goalType => text()();
  IntColumn get target => integer()();
  TextColumn get unit => text()();
  TextColumn get repeat => text()();

  /// Comma-separated weekday numbers, 1 = Monday.
  TextColumn get weekdays => text()();
  IntColumn get timesPerWeek => integer()();

  /// Comma-separated minutes of the day, e.g. "540,1080" for 9:00 and 18:00.
  TextColumn get reminders => text()();

  /// Calendar days as "yyyy-mm-dd", so they never shift with time zones.
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  TextColumn get note => text()();
  BoolColumn get archived => boolean()();
  IntColumn get updatedAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get habitId => text()();

  /// "yyyy-mm-dd".
  TextColumn get day => text()();
  IntColumn get value => integer()();
  BoolColumn get skipped => boolean()();
  TextColumn get note => text()();
  IntColumn get updatedAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {habitId, day};
}

@DataClassName('WidgetRow')
class WidgetConfigs extends Table {
  TextColumn get id => text()();

  /// Display order on the Widgets screen.
  IntColumn get position => integer()();

  /// The widget's settings as JSON.
  TextColumn get data => text()();
  IntColumn get updatedAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small values: app settings and sync bookmarks.
@DataClassName('KeyValueRow')
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Habits, Entries, WidgetConfigs, KeyValues])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The database file on the phone.
  factory AppDatabase.onDevice() => AppDatabase(driftDatabase(name: 'ovvas'));

  @override
  int get schemaVersion => 1;

  // ---- Key-value ----

  Future<String?> readValue(String key) async {
    final row = await (select(keyValues)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeValue(String key, String? value) async {
    if (value == null) {
      await (delete(keyValues)..where((t) => t.key.equals(key))).go();
    } else {
      await into(keyValues).insertOnConflictUpdate(KeyValuesCompanion.insert(key: key, value: value));
    }
  }

  // ---- Sync helpers ----

  /// Marks every row as not uploaded, e.g. after signing out, so the next
  /// account that signs in gets a full copy.
  Future<void> markAllDirty() => transaction(() async {
        await update(habits).write(const HabitsCompanion(dirty: Value(true)));
        await update(entries).write(const EntriesCompanion(dirty: Value(true)));
        await update(widgetConfigs).write(const WidgetConfigsCompanion(dirty: Value(true)));
      });

  Future<bool> get isEmpty async {
    final count = habits.id.count();
    final row = await (selectOnly(habits)..addColumns([count])).getSingle();
    return (row.read(count) ?? 0) == 0;
  }
}
