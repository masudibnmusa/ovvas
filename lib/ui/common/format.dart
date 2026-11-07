import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/habit.dart';

String _loc(BuildContext context) => Localizations.localeOf(context).toLanguageTag();

/// "Wednesday, October 21"
String formatLongDate(BuildContext context, DateTime d) => DateFormat.MMMMEEEEd(_loc(context)).format(d);

/// "October 2026"
String formatMonthYear(BuildContext context, DateTime d) => DateFormat.yMMMM(_loc(context)).format(d);

/// "Oct 21"
String formatShortDate(BuildContext context, DateTime d) => DateFormat.MMMd(_loc(context)).format(d);

/// "10/21"
String formatNumericDate(BuildContext context, DateTime d) => DateFormat.Md(_loc(context)).format(d);

// 1 Jan 2024 was a Monday, so day N of that month has weekday N.
DateTime _dayWithWeekday(int weekday) => DateTime(2024, 1, weekday);

/// "M" for Monday.
String weekdayNarrow(BuildContext context, int weekday) =>
    DateFormat('EEEEE', _loc(context)).format(_dayWithWeekday(weekday));

/// "Mon"
String weekdayShort(BuildContext context, int weekday) =>
    DateFormat.E(_loc(context)).format(_dayWithWeekday(weekday));

/// "Monday"
String weekdayLong(BuildContext context, int weekday) =>
    DateFormat.EEEE(_loc(context)).format(_dayWithWeekday(weekday));

String formatTime(BuildContext context, ReminderTime t) =>
    MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay(hour: t.hour, minute: t.minute));

String formatPercent(double? v) => v == null ? '–' : '${(v * 100).round()}%';
