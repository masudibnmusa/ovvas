import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../domain/habit.dart';
import '../../domain/widget_config.dart';
import 'database.dart';

/// Converts between app models, local database rows and cloud rows.

String newUuid() {
  final r = math.Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDay(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

T _enumByName<T extends Enum>(List<T> values, String name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

List<int> _ints(String s) => s.isEmpty ? const [] : s.split(',').map(int.parse).toList();

// ---- Habits ----

HabitsCompanion habitToRow(Habit h, int updatedAt) => HabitsCompanion.insert(
      id: h.id,
      name: h.name,
      iconIndex: h.iconIndex,
      colorIndex: h.colorIndex,
      goalType: h.goalType.name,
      target: h.target,
      unit: h.unit,
      repeat: h.repeat.name,
      weekdays: (h.weekdays.toList()..sort()).join(','),
      timesPerWeek: h.timesPerWeek,
      reminders: h.reminders.map((r) => r.minutesOfDay).join(','),
      startDate: dayKey(h.startDate),
      endDate: Value(h.endDate == null ? null : dayKey(h.endDate!)),
      note: h.note,
      archived: h.archived,
      updatedAt: updatedAt,
      deleted: const Value(false),
      dirty: const Value(true),
    );

Habit habitFromRow(HabitRow r) => Habit(
      id: r.id,
      name: r.name,
      iconIndex: r.iconIndex,
      colorIndex: r.colorIndex,
      goalType: _enumByName(GoalType.values, r.goalType, GoalType.yesNo),
      target: r.target,
      unit: r.unit,
      repeat: _enumByName(RepeatKind.values, r.repeat, RepeatKind.everyDay),
      weekdays: _ints(r.weekdays).toSet(),
      timesPerWeek: r.timesPerWeek,
      reminders: [for (final m in _ints(r.reminders)) ReminderTime(m ~/ 60, m % 60)],
      startDate: parseDay(r.startDate),
      endDate: r.endDate == null ? null : parseDay(r.endDate!),
      note: r.note,
      archived: r.archived,
    );

Map<String, Object?> habitRowToCloud(HabitRow r, String userId) => {
      'user_id': userId,
      'id': r.id,
      'name': r.name,
      'icon_index': r.iconIndex,
      'color_index': r.colorIndex,
      'goal_type': r.goalType,
      'target': r.target,
      'unit': r.unit,
      'repeat': r.repeat,
      'weekdays': r.weekdays,
      'times_per_week': r.timesPerWeek,
      'reminders': r.reminders,
      'start_date': r.startDate,
      'end_date': r.endDate,
      'note': r.note,
      'archived': r.archived,
      'updated_at': r.updatedAt,
      'deleted': r.deleted,
    };

HabitRow habitRowFromCloud(Map<String, dynamic> m) => HabitRow(
      id: m['id'] as String,
      name: m['name'] as String,
      iconIndex: m['icon_index'] as int,
      colorIndex: m['color_index'] as int,
      goalType: m['goal_type'] as String,
      target: m['target'] as int,
      unit: m['unit'] as String,
      repeat: m['repeat'] as String,
      weekdays: m['weekdays'] as String,
      timesPerWeek: m['times_per_week'] as int,
      reminders: m['reminders'] as String,
      startDate: m['start_date'] as String,
      endDate: m['end_date'] as String?,
      note: m['note'] as String,
      archived: m['archived'] as bool,
      updatedAt: m['updated_at'] as int,
      deleted: m['deleted'] as bool,
      dirty: false,
    );

// ---- Entries ----

EntriesCompanion entryToRow(String habitId, DateTime day, DayEntry e, int updatedAt) => EntriesCompanion.insert(
      habitId: habitId,
      day: dayKey(day),
      value: e.value,
      skipped: e.skipped,
      note: e.note,
      updatedAt: updatedAt,
      // An empty entry is stored as deleted so the removal syncs.
      deleted: Value(e.isEmpty),
      dirty: const Value(true),
    );

DayEntry entryFromRow(EntryRow r) => DayEntry(value: r.value, skipped: r.skipped, note: r.note);

Map<String, Object?> entryRowToCloud(EntryRow r, String userId) => {
      'user_id': userId,
      'habit_id': r.habitId,
      'day': r.day,
      'value': r.value,
      'skipped': r.skipped,
      'note': r.note,
      'updated_at': r.updatedAt,
      'deleted': r.deleted,
    };

EntryRow entryRowFromCloud(Map<String, dynamic> m) => EntryRow(
      habitId: m['habit_id'] as String,
      day: m['day'] as String,
      value: m['value'] as int,
      skipped: m['skipped'] as bool,
      note: m['note'] as String,
      updatedAt: m['updated_at'] as int,
      deleted: m['deleted'] as bool,
      dirty: false,
    );

// ---- Widgets ----

String _widgetJson(WidgetConfig w) => jsonEncode({
      'kind': w.kind.name,
      'size': w.size.name,
      'habitIds': w.habitIds,
      'theme': w.theme.name,
      'background': w.background.name,
      'opacity': w.opacity,
      'corner': w.corner.name,
      'textSize': w.textSize.name,
      'showTitle': w.showTitle,
      'showStreak': w.showStreak,
      'showDate': w.showDate,
      'showPercentage': w.showPercentage,
      'tapAction': w.tapAction.name,
      'firstWeekday': w.firstWeekday,
    });

WidgetConfigsCompanion widgetToRow(WidgetConfig w, int position, int updatedAt) => WidgetConfigsCompanion.insert(
      id: w.id,
      position: position,
      data: _widgetJson(w),
      updatedAt: updatedAt,
      deleted: const Value(false),
      dirty: const Value(true),
    );

WidgetConfig widgetFromRow(WidgetRow r) {
  final m = jsonDecode(r.data) as Map<String, dynamic>;
  return WidgetConfig(
    id: r.id,
    kind: _enumByName(WidgetKind.values, m['kind'] as String, WidgetKind.singleHabit),
    size: _enumByName(WidgetSize.values, m['size'] as String, WidgetSize.small2x2),
    habitIds: (m['habitIds'] as List).cast<String>(),
    theme: _enumByName(WidgetTheme.values, m['theme'] as String, WidgetTheme.device),
    background: _enumByName(WidgetBackground.values, m['background'] as String, WidgetBackground.solid),
    opacity: (m['opacity'] as num).toDouble(),
    corner: _enumByName(WidgetCorner.values, m['corner'] as String, WidgetCorner.rounded),
    textSize: _enumByName(WidgetTextSize.values, m['textSize'] as String, WidgetTextSize.medium),
    showTitle: m['showTitle'] as bool,
    showStreak: m['showStreak'] as bool,
    showDate: m['showDate'] as bool,
    showPercentage: m['showPercentage'] as bool,
    tapAction: _enumByName(WidgetTapAction.values, m['tapAction'] as String, WidgetTapAction.checkHabit),
    firstWeekday: m['firstWeekday'] as int,
  );
}

Map<String, Object?> widgetRowToCloud(WidgetRow r, String userId) => {
      'user_id': userId,
      'id': r.id,
      'position': r.position,
      'data': r.data,
      'updated_at': r.updatedAt,
      'deleted': r.deleted,
    };

WidgetRow widgetRowFromCloud(Map<String, dynamic> m) => WidgetRow(
      id: m['id'] as String,
      position: m['position'] as int,
      data: m['data'] as String,
      updatedAt: m['updated_at'] as int,
      deleted: m['deleted'] as bool,
      dirty: false,
    );
