import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/widget_config.dart';

String widgetKindName(BuildContext context, WidgetKind k) {
  final l = context.l10n;
  return switch (k) {
    WidgetKind.singleHabit => l.widgetSingleHabit,
    WidgetKind.todayList => l.widgetTodayList,
    WidgetKind.progressRing => l.widgetProgressRing,
    WidgetKind.weekStrip => l.widgetWeekStrip,
    WidgetKind.monthHeatmap => l.widgetMonthHeatmap,
    WidgetKind.streakCounter => l.widgetStreakCounter,
  };
}

String widgetKindDescription(BuildContext context, WidgetKind k) {
  final l = context.l10n;
  return switch (k) {
    WidgetKind.singleHabit => l.widgetSingleHabitDesc,
    WidgetKind.todayList => l.widgetTodayListDesc,
    WidgetKind.progressRing => l.widgetProgressRingDesc,
    WidgetKind.weekStrip => l.widgetWeekStripDesc,
    WidgetKind.monthHeatmap => l.widgetMonthHeatmapDesc,
    WidgetKind.streakCounter => l.widgetStreakCounterDesc,
  };
}

IconData widgetKindIcon(WidgetKind k) => switch (k) {
      WidgetKind.singleHabit => Icons.check_circle_outline_rounded,
      WidgetKind.todayList => Icons.checklist_rounded,
      WidgetKind.progressRing => Icons.donut_large_rounded,
      WidgetKind.weekStrip => Icons.view_week_rounded,
      WidgetKind.monthHeatmap => Icons.calendar_month_rounded,
      WidgetKind.streakCounter => Icons.local_fire_department_rounded,
    };
