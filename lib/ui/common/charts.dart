import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/dates.dart';
import 'format.dart';
import 'motion.dart';

/// Circular progress ring with content in the middle.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 150,
    this.stroke = 14,
    this.color,
    this.trackColor,
    this.child,
  });

  final double progress;
  final double size;
  final double stroke;
  final Color? color;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: context.motion(900),
      curve: Curves.easeOutCubic,
      builder: (context, value, inner) => CustomPaint(
        painter: _RingPainter(value, stroke, color ?? c.primary, trackColor ?? c.ringTrack),
        child: inner,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color, this.track);

  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inner = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(inner, 0, math.pi * 2, false, paint..color = track);
    if (value <= 0) return;
    final sweep = math.pi * 2 * value;
    // Gradient runs from a lighter tint at the start to full color at the tip.
    final light = Color.lerp(color, Colors.white, 0.45)!;
    paint.shader = SweepGradient(
      startAngle: 0,
      endAngle: math.max(sweep, 0.01),
      colors: [light, color],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(inner);
    canvas.drawArc(inner, -math.pi / 2, sweep, false, paint);
    // Bright dot on the leading tip.
    paint.shader = null;
    final tipAngle = -math.pi / 2 + sweep;
    final tip = inner.center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * (inner.width / 2);
    canvas.drawCircle(tip, stroke * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track || old.stroke != stroke;
}

class BarDatum {
  const BarDatum({required this.label, required this.value, required this.semanticLabel, this.highlight = false});

  final String label;

  /// 0 to 1, or null for "no data".
  final double? value;
  final String semanticLabel;
  final bool highlight;
}

/// Vertical bars with a % axis, value labels and day labels. Values are always
/// written as text, so color is never the only signal.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.bars, this.height = 180, this.barWidth = 14, this.onTap});

  final List<BarDatum> bars;
  final double height;
  final double barWidth;
  final ValueChanged<int>? onTap;

  static const _valueSpace = 22.0;
  static const _axisWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final axisStyle = TextStyle(fontSize: 12, color: c.textSecondary);
    return Column(
      children: [
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final area = constraints.maxHeight - _valueSpace;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (fraction, label) in const [(1.0, '100%'), (0.5, '50%'), (0.0, '0%')])
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _valueSpace + area * (1 - fraction) - 8,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _axisWidth,
                            height: 16,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(label, style: axisStyle),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: c.border)),
                        ],
                      ),
                    ),
                  Positioned.fill(
                    left: _axisWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < bars.length; i++)
                          Expanded(
                            child: _Bar(
                              bar: bars[i],
                              area: area,
                              width: barWidth,
                              onTap: onTap == null ? null : () => onTap!(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: _axisWidth),
            for (final b in bars)
              Expanded(
                child: ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      b.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: b.highlight ? FontWeight.w800 : FontWeight.w600,
                        color: b.highlight ? c.textPrimary : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.bar, required this.area, required this.width, this.onTap});

  final BarDatum bar;
  final double area;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = bar.value;
    return Semantics(
      label: bar.semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: bar.highlight
                ? BoxDecoration(color: c.mint.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12))
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 18,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatPercent(v),
                      style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: v ?? 0),
                  duration: context.motion(700),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => Container(
                    width: width,
                    height: v == null ? 4 : math.max(4, (area - 4) * t),
                    decoration: BoxDecoration(
                      color: v == null ? c.border : null,
                      gradient: v == null
                          ? null
                          : LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [c.primary, Color.lerp(c.primary, kHabitColors[Accent.violet.colorIndex], 0.35)!],
                            ),
                      borderRadius: BorderRadius.circular(width / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarCell {
  const CalendarCell({
    required this.fill,
    required this.textColor,
    required this.semanticLabel,
    this.border,
    this.marked = false,
    this.enabled = true,
  });

  final Color fill;
  final Color textColor;
  final String semanticLabel;
  final Color? border;

  /// Shows a small check under the day number.
  final bool marked;
  final bool enabled;
}

/// Month grid with weekday headers. The caller decides how each day looks.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key, required this.month, required this.firstWeekday, required this.cellFor, this.onTap});

  final DateTime month;
  final int firstWeekday;
  final CalendarCell Function(DateTime day) cellFor;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final first = startOfMonth(month);
    final leading = (first.weekday - firstWeekday + 7) % 7;
    final count = daysInMonth(month);
    final rows = ((leading + count) / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: ExcludeSemantics(
                  child: Center(
                    child: Text(
                      weekdayNarrow(context, weekdayAt(i, firstWeekday)),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var col = 0; col < 7; col++) Expanded(child: _cell(context, r * 7 + col - leading + 1, count)),
            ],
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, int dayNumber, int count) {
    if (dayNumber < 1 || dayNumber > count) return const AspectRatio(aspectRatio: 1);
    final day = DateTime(month.year, month.month, dayNumber);
    final cell = cellFor(day);
    final radius = BorderRadius.circular(10);
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: AspectRatio(
        aspectRatio: 1,
        child: Semantics(
          button: onTap != null && cell.enabled,
          label: cell.semanticLabel,
          excludeSemantics: true,
          child: Material(
            color: cell.fill,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: cell.border == null ? BorderSide.none : BorderSide(color: cell.border!, width: 1.5),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: onTap != null && cell.enabled ? () => onTap!(day) : null,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cell.textColor),
                      ),
                      if (cell.marked) Icon(Icons.check_rounded, size: 11, color: cell.textColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One swatch plus label, for chart legends.
class LegendItem extends StatelessWidget {
  const LegendItem({super.key, required this.color, required this.label, this.border});

  final Color color;
  final String label;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border == null ? null : Border.all(color: border!, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
      ],
    );
  }
}

/// Thin rounded bar that glides to its new value.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({super.key, required this.value, this.color, this.track, this.height = 6});

  final double value;
  final Color? color;
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track ?? c.ringTrack)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: context.motion(Motion.slow + 200),
              curve: Motion.settle,
              builder: (context, v, _) => FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                alignment: AlignmentDirectional.centerStart,
                child: DecoratedBox(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(height), color: color ?? c.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
