import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/habit.dart';

/// Large rounded card with a soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.onLongPress,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [BoxShadow(color: c.shadow, blurRadius: 18, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: color ?? c.surface,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small uppercase section heading, e.g. "YOUR HABITS".
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.only(top: 24, bottom: 10),
  });

  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: c.textSecondary),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Field label above an input, e.g. "Habit name".
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Pill-shaped segmented control from the mockups (Daily | Weekly | Custom).
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({super.key, required this.options, required this.value, required this.onChanged});

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: [
          for (final (v, label) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: v == value,
                child: AnimatedContainer(
                  duration: context.motion(200),
                  curve: Curves.easeOut,
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: v == value ? c.primary : Colors.transparent,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => onChanged(v),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: v == value ? c.onPrimary : c.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "−  [ 10 ]  +" stepper from the mockups.
class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 9999,
    this.step = 1,
    this.unit,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          IconButton(
            tooltip: l.decrease,
            iconSize: 28,
            color: c.primary,
            onPressed: value - step >= min ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Semantics(
                liveRegion: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: c.primary)),
                    if (unit != null && unit!.isNotEmpty)
                      Text(unit!, style: TextStyle(fontSize: 12, color: c.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l.increase,
            iconSize: 28,
            color: c.primary,
            onPressed: value + step <= max ? () => onChanged(value + step) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

/// Habit icon in a soft colored circle.
class HabitAvatar extends StatelessWidget {
  const HabitAvatar({super.key, required this.iconIndex, required this.colorIndex, this.size = 48});

  HabitAvatar.of(Habit habit, {super.key, this.size = 48})
      : iconIndex = habit.iconIndex,
        colorIndex = habit.colorIndex;

  final int iconIndex;
  final int colorIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = habitTint(context, colorIndex);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: tint.background, shape: BoxShape.circle),
        child: Icon(kHabitIcons[iconIndex % kHabitIcons.length], color: tint.foreground, size: size * 0.5),
      ),
    );
  }
}

/// Amber flame plus "5-day streak".
class StreakLabel extends StatelessWidget {
  const StreakLabel(this.days, {super.key, this.fontSize = 14});

  final int days;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department_rounded, size: fontSize + 4, color: c.streak),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            context.l10n.dayStreak(days),
            style: TextStyle(fontSize: fontSize, color: c.textSecondary, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Small stat card: big value, label below, optional trend line.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label, this.trend});

  final String value;
  final String label;
  final Widget? trend;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: c.textPrimary)),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500)),
          if (trend != null) ...[const SizedBox(height: 6), trend!],
        ],
      ),
    );
  }
}

/// Friendly illustration, one sentence, one button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.eco_rounded,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: c.mint, shape: BoxShape.circle),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 18,
                    top: 20,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
                    ),
                  ),
                  Icon(icon, size: 56, color: c.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary, fontSize: 14)),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Teal up arrow or neutral gray down arrow with a percentage. Never red.
class TrendBadge extends StatelessWidget {
  const TrendBadge({super.key, required this.delta, required this.comparedTo});

  /// Change in percent (or percentage points for rates).
  final double delta;
  final String comparedTo;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final rounded = delta.round();
    final up = rounded > 0;
    final flat = rounded == 0;
    final color = up ? c.trendUp : c.trendDown;
    final text = flat ? l.trendSame : '${rounded.abs()}%';
    return Semantics(
      label: flat ? '${l.trendSame} $comparedTo' : (up ? l.trendUp(rounded.abs(), comparedTo) : l.trendDown(rounded.abs(), comparedTo)),
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          if (!flat) Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 14, color: color),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: flat ? c.textSecondary : color)),
          Text(' $comparedTo', style: TextStyle(fontSize: 12, color: c.textSecondary)),
        ],
      ),
    );
  }
}
