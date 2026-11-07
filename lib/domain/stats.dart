import 'dates.dart';
import 'habit.dart';

typedef EntryLookup = DayEntry? Function(String habitId, DateTime day);

enum DayStatus { done, partial, missed, skipped, pending, notScheduled, future }

/// Totals for one day across a set of habits.
class DayAgg {
  DayAgg(this.day);

  final DateTime day;
  int scheduled = 0;
  int done = 0;
  final List<Habit> doneHabits = [];

  double? get rate => scheduled == 0 ? null : done / scheduled;
  bool get perfect => scheduled > 0 && done == scheduled;
}

class PeriodSummary {
  PeriodSummary(this.days);

  final List<DayAgg> days;

  int get scheduled => days.fold(0, (sum, d) => sum + d.scheduled);
  int get done => days.fold(0, (sum, d) => sum + d.done);
  double? get rate => scheduled == 0 ? null : done / scheduled;
  int get perfectDays => days.where((d) => d.perfect).length;

  DayAgg? get bestDay {
    DayAgg? best;
    for (final d in days) {
      final r = d.rate;
      if (r == null || d.done == 0) continue;
      if (best == null || r > best.rate! || (r == best.rate! && d.done > best.done)) best = d;
    }
    return best;
  }
}

class HabitPeriodStat {
  const HabitPeriodStat(this.habit, this.done, this.scheduled);

  final Habit habit;
  final int done;
  final int scheduled;

  double? get rate => scheduled == 0 ? null : done / scheduled;
}

/// Streak and completion maths. Pure: everything comes from [lookup] and [today].
class Stats {
  Stats(this.lookup, {required DateTime today}) : today = dateOnly(today);

  final EntryLookup lookup;
  final DateTime today;

  static const _maxLookback = 3660;

  bool isDone(Habit h, DayEntry? e) => e != null && !e.skipped && e.value >= h.target;

  DayStatus status(Habit h, DateTime day) {
    final d = dateOnly(day);
    if (d.isAfter(today)) return DayStatus.future;
    if (!h.isScheduledOn(d)) return DayStatus.notScheduled;
    final e = lookup(h.id, d);
    if (e != null && e.skipped) return DayStatus.skipped;
    if (isDone(h, e)) return DayStatus.done;
    if (e != null && e.value > 0) return DayStatus.partial;
    return d == today ? DayStatus.pending : DayStatus.missed;
  }

  /// Whether a day counts toward completion rates. Skipped days, days before
  /// the start date and future days never count. Today only counts once it is
  /// done, so a day still in progress never lowers the rate.
  bool _counts(DateTime day, DayStatus s) => switch (s) {
        DayStatus.done => true,
        DayStatus.partial || DayStatus.missed => day != today,
        _ => false,
      };

  int currentStreak(Habit h) {
    final start = dateOnly(h.startDate);
    var streak = 0;
    var d = today;
    for (var i = 0; i < _maxLookback && !d.isBefore(start); i++) {
      final s = status(h, d);
      if (s == DayStatus.done) {
        streak++;
      } else if (_counts(d, s)) {
        break;
      }
      d = addDays(d, -1);
    }
    return streak;
  }

  int bestStreak(Habit h, {DateTime? from, DateTime? to}) {
    var d = dateOnly(h.startDate);
    if (from != null && from.isAfter(d)) d = dateOnly(from);
    final end = (to == null || to.isAfter(today)) ? today : dateOnly(to);
    var run = 0;
    var best = 0;
    while (!d.isAfter(end)) {
      final s = status(h, d);
      if (s == DayStatus.done) {
        run++;
        if (run > best) best = run;
      } else if (_counts(d, s)) {
        run = 0;
      }
      d = addDays(d, 1);
    }
    return best;
  }

  HabitPeriodStat habitStat(Habit h, DateTime from, DateTime to) {
    var done = 0;
    var scheduled = 0;
    for (final d in daysInRange(from, to)) {
      final s = status(h, d);
      if (!_counts(d, s)) continue;
      scheduled++;
      if (s == DayStatus.done) done++;
    }
    return HabitPeriodStat(h, done, scheduled);
  }

  PeriodSummary summarize(List<Habit> habits, DateTime from, DateTime to) {
    final days = <DayAgg>[];
    for (final d in daysInRange(from, to)) {
      final agg = DayAgg(d);
      for (final h in habits) {
        final s = status(h, d);
        if (!_counts(d, s)) continue;
        agg.scheduled++;
        if (s == DayStatus.done) {
          agg.done++;
          agg.doneHabits.add(h);
        }
      }
      days.add(agg);
    }
    return PeriodSummary(days);
  }

  Map<int, double> weekdayRates(List<Habit> habits, DateTime from, DateTime to) {
    final done = <int, int>{};
    final scheduled = <int, int>{};
    for (final d in summarize(habits, from, to).days) {
      if (d.scheduled == 0) continue;
      final w = d.day.weekday;
      done[w] = (done[w] ?? 0) + d.done;
      scheduled[w] = (scheduled[w] ?? 0) + d.scheduled;
    }
    return {for (final w in scheduled.keys) w: (done[w] ?? 0) / scheduled[w]!};
  }

  /// Weekday with the highest rate, or null when there is no clear winner.
  int? bestWeekday(List<Habit> habits, DateTime from, DateTime to) =>
      _extremeWeekday(weekdayRates(habits, from, to), best: true);

  /// Weekday with the lowest rate, or null when there is no clear loser.
  int? hardestWeekday(List<Habit> habits, DateTime from, DateTime to) =>
      _extremeWeekday(weekdayRates(habits, from, to), best: false);

  int? _extremeWeekday(Map<int, double> rates, {required bool best}) {
    if (rates.length < 2) return null;
    final hi = rates.entries.reduce((a, b) => b.value > a.value ? b : a);
    final lo = rates.entries.reduce((a, b) => b.value < a.value ? b : a);
    if (hi.value == lo.value) return null;
    return best ? hi.key : lo.key;
  }
}
