import 'dart:math' as math;

import '../domain/dates.dart';
import '../domain/habit.dart';
import '../domain/widget_config.dart';
import 'habit_store.dart';

/// Fills [store] with a few habits and ~5 months of believable history, so
/// every screen has something to show while the backend is not built yet.
void seedSampleData(HabitStore store) {
  final today = store.today;
  final rnd = math.Random(42);
  final start = addDays(today, -150);

  final specs = <(Habit, double)>[
    (
      Habit(
        id: store.newId(),
        name: 'Drink water',
        iconIndex: 0,
        colorIndex: 2,
        goalType: GoalType.count,
        target: 8,
        unit: 'glasses',
        startDate: start,
        reminders: const [ReminderTime(9, 0), ReminderTime(15, 0)],
      ),
      0.82,
    ),
    (
      Habit(
        id: store.newId(),
        name: 'Read 10 pages',
        iconIndex: 1,
        colorIndex: 3,
        goalType: GoalType.count,
        target: 10,
        unit: 'pages',
        startDate: start,
        reminders: const [ReminderTime(21, 0)],
      ),
      0.7,
    ),
    (
      Habit(
        id: store.newId(),
        name: 'Take a walk',
        iconIndex: 2,
        colorIndex: 1,
        startDate: addDays(start, 20),
        reminders: const [ReminderTime(18, 0)],
      ),
      0.76,
    ),
    (
      Habit(
        id: store.newId(),
        name: 'Stretch',
        iconIndex: 3,
        colorIndex: 6,
        repeat: RepeatKind.weekdays,
        weekdays: const {1, 2, 3, 4, 5},
        startDate: start,
      ),
      0.55,
    ),
    (
      Habit(
        id: store.newId(),
        name: 'Meditate',
        iconIndex: 11,
        colorIndex: 0,
        goalType: GoalType.time,
        target: 10,
        startDate: addDays(today, -60),
      ),
      0.62,
    ),
  ];

  for (final (h, chance) in specs) {
    store.addHabit(h);
    for (var d = dateOnly(h.startDate); d.isBefore(today); d = addDays(d, 1)) {
      if (!h.isScheduledOn(d)) continue;
      final daysAgo = daysBetween(d, today);
      // Recent weeks are a little stronger so the sample shows an upward trend.
      final trend = daysAgo < 30 ? 0.08 : -0.05;
      final weekendDip = d.weekday >= DateTime.saturday ? 0.12 : 0.0;
      final r = rnd.nextDouble();
      if (daysAgo <= 4 && h.name != 'Stretch') {
        store.setValue(h, d, h.target);
      } else if (r < chance + trend - weekendDip) {
        store.setValue(h, d, h.target);
      } else if (r > 0.97) {
        store.setSkipped(h, d, true);
      } else if (h.isMeasured && r < chance + 0.2) {
        store.setValue(h, d, (h.target / 2).round());
      }
    }
  }

  final hs = store.habits;
  store.setValue(hs[0], today, 5);
  store.setValue(hs[1], today, 10);
  store.setValue(hs[2], today, 1);
  store.setNote(hs[1], addDays(today, -2), 'Finished chapter 4. Short chapters help.');
  store.setNote(hs[0], addDays(today, -6), 'Hot day, carried a bottle everywhere.');

  store.saveWidget(WidgetConfig(
    id: store.newWidgetId(),
    kind: WidgetKind.todayList,
    size: WidgetSize.medium4x2,
    habitIds: [hs[0].id, hs[1].id, hs[2].id],
  ));
}
