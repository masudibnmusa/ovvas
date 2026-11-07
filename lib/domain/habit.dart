import 'dates.dart';

enum GoalType { yesNo, count, time }

enum RepeatKind { everyDay, weekdays, timesPerWeek }

class ReminderTime implements Comparable<ReminderTime> {
  const ReminderTime(this.hour, this.minute);

  final int hour;
  final int minute;

  int get minutesOfDay => hour * 60 + minute;

  @override
  int compareTo(ReminderTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.iconIndex,
    required this.colorIndex,
    required this.startDate,
    this.goalType = GoalType.yesNo,
    this.target = 1,
    this.unit = '',
    this.repeat = RepeatKind.everyDay,
    this.weekdays = allWeekdays,
    this.timesPerWeek = 3,
    this.reminders = const [],
    this.endDate,
    this.note = '',
    this.archived = false,
  });

  static const allWeekdays = {1, 2, 3, 4, 5, 6, 7};

  final String id;
  final String name;
  final int iconIndex;
  final int colorIndex;
  final GoalType goalType;

  /// Amount needed to complete the day: 1 for Yes/No, a count, or minutes.
  final int target;
  final String unit;
  final RepeatKind repeat;

  /// Used when [repeat] is [RepeatKind.weekdays]. 1 = Monday.
  final Set<int> weekdays;
  final int timesPerWeek;
  final List<ReminderTime> reminders;
  final DateTime startDate;
  final DateTime? endDate;
  final String note;
  final bool archived;

  bool get isMeasured => goalType != GoalType.yesNo;

  /// How much one tap on "+" adds.
  int get step => goalType == GoalType.time ? 5 : 1;

  bool isScheduledOn(DateTime day) {
    final d = dateOnly(day);
    if (d.isBefore(dateOnly(startDate))) return false;
    if (endDate != null && d.isAfter(dateOnly(endDate!))) return false;
    return switch (repeat) {
      RepeatKind.everyDay => true,
      RepeatKind.weekdays => weekdays.contains(d.weekday),
      // Shown every day; the user picks which days to do it.
      RepeatKind.timesPerWeek => true,
    };
  }

  Habit copyWith({
    String? name,
    int? iconIndex,
    int? colorIndex,
    GoalType? goalType,
    int? target,
    String? unit,
    RepeatKind? repeat,
    Set<int>? weekdays,
    int? timesPerWeek,
    List<ReminderTime>? reminders,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? note,
    bool? archived,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      colorIndex: colorIndex ?? this.colorIndex,
      goalType: goalType ?? this.goalType,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      repeat: repeat ?? this.repeat,
      weekdays: weekdays ?? this.weekdays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      reminders: reminders ?? this.reminders,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      note: note ?? this.note,
      archived: archived ?? this.archived,
    );
  }
}

/// What the user logged for one habit on one day.
class DayEntry {
  const DayEntry({this.value = 0, this.skipped = false, this.note = ''});

  final int value;
  final bool skipped;
  final String note;

  bool get isEmpty => value == 0 && !skipped && note.isEmpty;

  DayEntry copyWith({int? value, bool? skipped, String? note}) => DayEntry(
        value: value ?? this.value,
        skipped: skipped ?? this.skipped,
        note: note ?? this.note,
      );
}
