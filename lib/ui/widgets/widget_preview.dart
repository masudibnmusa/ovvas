import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../../domain/widget_config.dart';
import '../common/charts.dart';
import '../common/format.dart';

/// Resolved colors for a widget's chosen theme.
class WidgetPalette {
  const WidgetPalette({
    required this.background,
    required this.foreground,
    required this.secondary,
    required this.accent,
    required this.onAccent,
    required this.track,
    required this.brightness,
  });

  final Color background;
  final Color foreground;
  final Color secondary;
  final Color accent;
  final Color onAccent;
  final Color track;
  final Brightness brightness;

  factory WidgetPalette.resolve(BuildContext context, WidgetTheme theme) {
    if (theme == WidgetTheme.accent) {
      final c = context.colors;
      return WidgetPalette(
        background: c.primary,
        foreground: c.onPrimary,
        secondary: c.onPrimary.withValues(alpha: 0.8),
        accent: c.onPrimary,
        onAccent: c.primary,
        track: c.onPrimary.withValues(alpha: 0.25),
        brightness: c.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      );
    }
    final b = switch (theme) {
      WidgetTheme.light => Brightness.light,
      WidgetTheme.dark => Brightness.dark,
      _ => Theme.of(context).brightness,
    };
    final c = AppColors.of(b);
    return WidgetPalette(
      background: c.surface,
      foreground: c.textPrimary,
      secondary: c.textSecondary,
      accent: c.primary,
      onAccent: c.onPrimary,
      track: c.ringTrack,
      brightness: b,
    );
  }
}

/// Mid-tone stand-in for a home-screen wallpaper, used for contrast checks.
const kWallpaperSample = Color(0xFF5F7C78);

Color effectiveWidgetBackground(WidgetConfig config, WidgetPalette p) =>
    config.background == WidgetBackground.transparent
        ? Color.alphaBlend(p.background.withValues(alpha: config.opacity), kWallpaperSample)
        : p.background;

/// WCAG contrast ratio between two colors.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Live rendering of a home-screen widget from its config and current data.
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({super.key, required this.config, this.cellSize = 80});

  final WidgetConfig config;

  /// Size of one launcher grid cell.
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final p = WidgetPalette.resolve(context, config.theme);
    final w = config.size.columns * cellSize;
    final h = config.size.rows * cellSize;
    final radius = switch (config.corner) {
      WidgetCorner.square => 6.0,
      WidgetCorner.rounded => 22.0,
      WidgetCorner.round => math.min(40.0, math.min(w, h) / 2),
    };
    final scale = switch (config.textSize) {
      WidgetTextSize.small => 0.9,
      WidgetTextSize.medium => 1.0,
      WidgetTextSize.large => 1.15,
    };
    final decoration = switch (config.background) {
      WidgetBackground.solid => BoxDecoration(color: p.background, borderRadius: BorderRadius.circular(radius)),
      WidgetBackground.gradient => BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.background, Color.lerp(p.background, p.accent, 0.22)!],
          ),
        ),
      WidgetBackground.transparent => BoxDecoration(
          color: p.background.withValues(alpha: config.opacity),
          borderRadius: BorderRadius.circular(radius),
        ),
    };

    return Semantics(
      label: context.l10n.widgetPreviewSemantics,
      child: SizedBox(
        width: w,
        height: h,
        child: DecoratedBox(
          decoration: decoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: EdgeInsets.all(config.size.rows == 1 ? 10 : 14),
              child: MediaQuery.withNoTextScaling(
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: p.foreground, fontSize: 13 * scale, fontWeight: FontWeight.w500),
                  child: IconTheme(
                    data: IconThemeData(color: p.accent),
                    child: _content(context, p, scale),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Habit> _habits(BuildContext context) {
    final store = context.store;
    if (config.habitIds.isEmpty) return store.habits;
    return [for (final id in config.habitIds) ?store.habitById(id)].where((h) => !h.archived).toList();
  }

  Widget _content(BuildContext context, WidgetPalette p, double s) {
    final store = context.store;
    final stats = store.stats;
    final l = context.l10n;
    final today = store.today;
    final habits = _habits(context);
    final todays = habits.where((h) => h.isScheduledOn(today)).toList();
    final doneCount = todays.where((h) => stats.status(h, today) == DayStatus.done).length;
    final rate = todays.isEmpty ? 0.0 : doneCount / todays.length;
    final title = TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w700, color: p.foreground);
    final small = TextStyle(fontSize: 11 * s, color: p.secondary);

    switch (config.kind) {
      case WidgetKind.singleHabit:
        if (habits.isEmpty) return Center(child: Text(l.widgetPickHabit, style: small, textAlign: TextAlign.center));
        final h = habits.first;
        final done = stats.status(h, today) == DayStatus.done;
        final tint = habitTintFor(p.brightness, h.colorIndex);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config.showTitle) Text(h.name, style: title, maxLines: 2, overflow: TextOverflow.ellipsis),
            Expanded(
              child: Center(
                child: FittedBox(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? p.accent : tint.background,
                      border: done ? null : Border.all(color: p.accent, width: 2),
                    ),
                    child: Icon(done ? Icons.check_rounded : kHabitIcons[h.iconIndex % kHabitIcons.length],
                        color: done ? p.onAccent : tint.foreground, size: 28),
                  ),
                ),
              ),
            ),
            if (config.showStreak) _streak(stats.currentStreak(h), small, p),
          ],
        );

      case WidgetKind.todayList:
        final max = maxHabitsFor(config.size);
        final shown = (config.habitIds.isEmpty ? todays : habits).take(max).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (config.showTitle) Expanded(child: Text(l.today, style: title)) else const Spacer(),
                if (config.showPercentage)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: p.track, borderRadius: BorderRadius.circular(10)),
                    child: Text(formatPercent(rate), style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700, color: p.foreground)),
                  ),
              ],
            ),
            if (config.showDate) Text(formatShortDate(context, today), style: small),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (shown.isEmpty) Text(l.widgetNothingToday, style: small),
                  for (final h in shown)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            stats.status(h, today) == DayStatus.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 18 * s,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(h.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          if (config.showStreak && stats.currentStreak(h) > 0) _streak(stats.currentStreak(h), small, p, compact: true),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      case WidgetKind.progressRing:
        return Column(
          children: [
            if (config.showTitle) Text(l.today, style: title),
            Expanded(
              child: Center(
                child: FittedBox(
                  child: ProgressRing(
                    progress: rate,
                    size: 110,
                    stroke: 11,
                    color: p.accent,
                    trackColor: p.track,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$doneCount/${todays.length}', style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800, color: p.foreground)),
                        if (config.showPercentage) Text(formatPercent(rate), style: small),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case WidgetKind.weekStrip:
        final start = startOfWeek(today, config.firstWeekday);
        final week = stats.summarize(habits, start, addDays(start, 6)).days;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (config.showTitle) Expanded(child: Text(l.thisWeek, style: title)) else const Spacer(),
                if (config.showPercentage) Text(formatPercent(stats.summarize(habits, start, today).rate), style: small),
              ],
            ),
            if (config.showDate) Text('${formatShortDate(context, start)} – ${formatShortDate(context, addDays(start, 6))}', style: small),
            const Spacer(),
            Row(
              children: [
                for (final d in week)
                  Expanded(
                    child: Column(
                      children: [
                        Text(weekdayNarrow(context, d.day.weekday), style: small.copyWith(fontWeight: d.day == today ? FontWeight.w800 : null)),
                        const SizedBox(height: 6),
                        _dayDot(d, p),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
          ],
        );

      case WidgetKind.monthHeatmap:
        final month = startOfMonth(today);
        final days = {for (final d in stats.summarize(habits, month, endOfMonth(month)).days) d.day: d};
        final leading = (month.weekday - config.firstWeekday + 7) % 7;
        final count = daysInMonth(month);
        final rows = ((leading + count) / 7).ceil();
        final ac = AppColors.of(p.brightness);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config.showTitle)
              Text(config.habitIds.isEmpty ? l.allHabits : (habits.isEmpty ? '' : habits.first.name),
                  style: title, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (config.showDate) Text(formatMonthYear(context, month), style: small),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(builder: (context, box) {
                final cell = math.min(box.maxWidth / 7, box.maxHeight / rows);
                return Column(
                  children: [
                    for (var r = 0; r < rows; r++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var col = 0; col < 7; col++)
                            Builder(builder: (_) {
                              final n = r * 7 + col - leading + 1;
                              final agg = (n >= 1 && n <= count) ? days[DateTime(month.year, month.month, n)] : null;
                              final r0 = agg?.rate;
                              final inMonth = n >= 1 && n <= count;
                              return Container(
                                width: cell - 3,
                                height: cell - 3,
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(cell / 4),
                                  color: !inMonth
                                      ? Colors.transparent
                                      : r0 == null
                                          ? p.track.withValues(alpha: 0.5)
                                          : Color.lerp(p.track, p.accent, 0.15 + r0 * 0.85),
                                  border: inMonth && n == today.day ? Border.all(color: p.foreground, width: 1.5) : null,
                                ),
                              );
                            }),
                        ],
                      ),
                  ],
                );
              }),
            ),
            if (config.showStreak && habits.isNotEmpty)
              _streak(habits.map(stats.currentStreak).reduce(math.max), small, p, color: ac.streak),
          ],
        );

      case WidgetKind.streakCounter:
        final h = habits.isEmpty ? null : habits.first;
        final streak = h == null ? 0 : stats.currentStreak(h);
        return Row(
          children: [
            Icon(Icons.local_fire_department_rounded, size: 30 * s, color: AppColors.of(p.brightness).streak),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$streak', style: TextStyle(fontSize: 24 * s, fontWeight: FontWeight.w800, color: p.foreground, height: 1.1)),
                    if (config.showTitle && h != null) Text(h.name, style: small, maxLines: 1),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _dayDot(DayAgg d, WidgetPalette p) {
    final rate = d.rate;
    const size = 22.0;
    if (rate == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.track, width: 2)),
      );
    }
    final full = rate >= 1;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: full ? p.accent : (rate > 0 ? p.accent.withValues(alpha: 0.35) : Colors.transparent),
        border: full ? null : Border.all(color: p.accent, width: 2),
      ),
      child: full ? Icon(Icons.check_rounded, size: 14, color: p.onAccent) : null,
    );
  }

  Widget _streak(int days, TextStyle style, WidgetPalette p, {bool compact = false, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department_rounded, size: 14, color: color ?? AppColors.of(p.brightness).streak),
        const SizedBox(width: 2),
        Text('$days', style: style.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
