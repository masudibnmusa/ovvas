import 'package:flutter_test/flutter_test.dart';
import 'package:ovvas/domain/habit.dart';
import 'package:ovvas/domain/stats.dart';

void main() {
  // Wednesday. The week before runs Mon 12 – Sun 18 October.
  final today = DateTime(2026, 10, 21);

  Habit weekly(String id) => Habit(
    id: id,
    name: id,
    iconIndex: 0,
    colorIndex: 0,
    repeat: RepeatKind.timesPerWeek,
    timesPerWeek: 3,
    startDate: DateTime(2026, 10, 12),
  );

  final done = {
    'full': {12, 14, 16},
    'short': {12},
  };
  final stats = Stats(
    (id, day) => day.month == 10 && (done[id]?.contains(day.day) ?? false) ? const DayEntry(value: 1) : null,
    today: today,
  );

  test('a weekly quota met on any days is a perfect week', () {
    final s = stats.habitStat(weekly('full'), DateTime(2026, 10, 12), DateTime(2026, 10, 18));
    expect((s.done, s.scheduled), (3, 3));
    expect(stats.currentStreak(weekly('full')), 3, reason: 'rest days do not break the streak');
  });

  test('a missed quota counts only the check-ins that were missing', () {
    final s = stats.habitStat(weekly('short'), DateTime(2026, 10, 12), DateTime(2026, 10, 18));
    expect((s.done, s.scheduled), (1, 3));
    expect(stats.status(weekly('short'), DateTime(2026, 10, 18)), DayStatus.missed);
    expect(stats.status(weekly('short'), DateTime(2026, 10, 13)), DayStatus.notScheduled);
  });

  test('early in the week nothing is due yet', () {
    expect(stats.status(weekly('short'), today), DayStatus.notScheduled);
  });
}
