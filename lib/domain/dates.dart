/// Date helpers. All app dates are local calendar days with no time part.
library;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// Whole calendar days from [a] to [b], safe across daylight-saving changes.
int daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

/// First day of the week containing [d]. [firstWeekday] uses DateTime.monday..sunday.
DateTime startOfWeek(DateTime d, int firstWeekday) {
  final day = dateOnly(d);
  return addDays(day, -((day.weekday - firstWeekday + 7) % 7));
}

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

int daysInMonth(DateTime d) => endOfMonth(d).day;

/// Weekday number (1 = Monday) at position [index] of a week starting on [firstWeekday].
int weekdayAt(int index, int firstWeekday) => (firstWeekday - 1 + index) % 7 + 1;

Iterable<DateTime> daysInRange(DateTime from, DateTime to) sync* {
  for (var d = dateOnly(from); !d.isAfter(to); d = addDays(d, 1)) {
    yield d;
  }
}
