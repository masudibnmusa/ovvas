import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovvas/data/habit_store.dart';
import 'package:ovvas/data/local/database.dart';
import 'package:ovvas/data/sample_data.dart';
import 'package:ovvas/data/settings_controller.dart';
import 'package:ovvas/domain/dates.dart';
import 'package:ovvas/domain/habit.dart';
import 'package:ovvas/domain/widget_config.dart';

final _now = DateTime(2026, 10, 21, 9, 30);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<HabitStore> reopen() async {
    final store = HabitStore(clock: () => _now, db: db);
    await store.reload();
    return store;
  }

  test('habits, check-ins and widgets survive a restart', () async {
    final a = HabitStore(clock: () => _now, db: db);
    final today = a.today;
    final h = Habit(
      id: a.newId(),
      name: 'Read',
      iconIndex: 1,
      colorIndex: 2,
      goalType: GoalType.count,
      target: 10,
      unit: 'pages',
      repeat: RepeatKind.weekdays,
      weekdays: const {1, 3, 5},
      reminders: const [ReminderTime(21, 30)],
      startDate: addDays(today, -5),
      endDate: addDays(today, 30),
      note: 'Before bed',
    );
    a.addHabit(h);
    a.setValue(h, today, 7);
    a.setNote(h, today, 'Good chapter');
    a.setSkipped(h, addDays(today, -1), true);
    a.saveWidget(WidgetConfig(id: a.newWidgetId(), kind: WidgetKind.todayList, size: WidgetSize.large4x4, habitIds: [h.id]));
    await a.flush();

    final b = await reopen();
    final h2 = b.habitById(h.id)!;
    expect(h2.name, 'Read');
    expect(h2.goalType, GoalType.count);
    expect(h2.weekdays, {1, 3, 5});
    expect(h2.reminders, [const ReminderTime(21, 30)]);
    expect(h2.startDate, addDays(today, -5));
    expect(h2.endDate, addDays(today, 30));
    expect(h2.note, 'Before bed');
    expect(b.entry(h.id, today)!.value, 7);
    expect(b.entry(h.id, today)!.note, 'Good chapter');
    expect(b.entry(h.id, addDays(today, -1))!.skipped, isTrue);
    expect(b.widgets.single.size, WidgetSize.large4x4);
    expect(b.widgets.single.habitIds, [h.id]);
  });

  test('undoing a check-in and deleting a habit are saved, and marked for upload', () async {
    final a = HabitStore(clock: () => _now, db: db);
    seedSampleData(a);
    final water = a.habits.first;
    final walk = a.habits.firstWhere((x) => x.name == 'Take a walk');
    a.setValue(water, a.today, 0);
    a.deleteHabit(walk.id);
    await a.flush();

    final b = await reopen();
    expect(b.entry(water.id, b.today), isNull);
    expect(b.habitById(walk.id), isNull);
    expect(b.habits.length, 4);
    expect(b.widgets.single.habitIds, isNot(contains(walk.id)));

    final deleted = await (db.select(db.habits)..where((t) => t.id.equals(walk.id))).getSingle();
    expect(deleted.deleted, isTrue);
    expect(deleted.dirty, isTrue);
  });

  test('settings survive a restart', () async {
    SettingsController(db: db)
      ..themeMode = ThemeMode.dark
      ..userName = 'Masud'
      ..quietStart = const ReminderTime(23, 15);
    await Future<void>.delayed(Duration.zero);

    final s = SettingsController(db: db);
    await s.load();
    expect(s.themeMode, ThemeMode.dark);
    expect(s.userName, 'Masud');
    expect(s.quietStart, const ReminderTime(23, 15));
  });
}
