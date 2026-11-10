import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/habit.dart';
import 'motion.dart';

/// Large rounded card with soft layered depth. Tappable cards shrink a
/// little under the finger.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
    this.onTap,
    this.onLongPress,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = BorderRadius.circular(radius);
    final tappable = onTap != null || onLongPress != null;
    final card = AnimatedContainer(
      duration: context.motion(Motion.base),
      curve: Motion.enter,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.surface) : null,
        gradient: gradient,
        borderRadius: shape,
        border: gradient == null ? Border.all(color: c.cardEdge) : null,
        boxShadow: c.raised,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return Pressable(enabled: tappable, scale: 0.98, child: card);
  }
}

/// Small uppercase section heading, e.g. "YOUR HABITS".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing, this.padding = const EdgeInsets.only(top: 24, bottom: 10)});

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

/// Pill-shaped segmented control (Daily | Weekly | Custom). The selected
/// thumb slides between options.
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({super.key, required this.options, required this.value, required this.onChanged});

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = options.indexWhere((o) => o.$1 == value);
    final n = options.length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          if (selected >= 0)
            Positioned.fill(
              child: AnimatedAlign(
                duration: context.motion(Motion.base + 40),
                curve: Motion.settle,
                alignment: AlignmentDirectional(
                  n == 1 ? 0 : -1 + 2 * selected / (n - 1),
                  0,
                ).resolve(Directionality.of(context)),
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: c.primary,
                      shadows: [BoxShadow(color: c.glow, blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              for (final (v, label) in options)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: v == value,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () {
                          if (v != value) context.haptic(soft: true);
                          onChanged(v);
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                              child: AnimatedDefaultTextStyle(
                                duration: context.motion(Motion.base),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: v == value ? FontWeight.w700 : FontWeight.w600,
                                  color: v == value ? c.onPrimary : c.textPrimary,
                                  fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                                ),
                                child: Text(label, textAlign: TextAlign.center),
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
                    AnimatedSwitcher(
                      duration: context.motion(Motion.base),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(anim), child: child),
                      ),
                      child: Text(
                        '$value',
                        key: ValueKey(value),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: c.primary),
                      ),
                    ),
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

/// Habit icon in a soft colored circle. With a [heroTag] it flies between
/// screens (list card to detail page).
class HabitAvatar extends StatelessWidget {
  const HabitAvatar({super.key, required this.iconIndex, required this.colorIndex, this.size = 48, this.heroTag});

  HabitAvatar.of(Habit habit, {super.key, this.size = 48, bool hero = false})
    : iconIndex = habit.iconIndex,
      colorIndex = habit.colorIndex,
      heroTag = hero ? 'habit-avatar-${habit.id}' : null;

  final int iconIndex;
  final int colorIndex;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final tint = habitTint(context, colorIndex);
    final avatar = AnimatedContainer(
      duration: context.motion(Motion.base),
      curve: Motion.enter,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(tint.background, Colors.white, 0.25)!, tint.background],
        ),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(Motion.base),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: Icon(
          kHabitIcons[iconIndex % kHabitIcons.length],
          key: ValueKey(iconIndex),
          color: tint.foreground,
          size: size * 0.5,
        ),
      ),
    );
    return ExcludeSemantics(
      child: heroTag == null
          ? avatar
          : Hero(
              tag: heroTag!,
              child: Material(type: MaterialType.transparency, child: avatar),
            ),
    );
  }
}

/// Icon in a small rounded square filled with an accent color. Used for
/// settings rows, stat tiles and list items so each kind reads at a glance.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, this.accent, {super.key, this.size = 36});

  final IconData icon;
  final Accent accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = accentTint(context, accent);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(tint.background, Colors.white, 0.2)!, tint.background],
          ),
        ),
        child: Icon(icon, size: size * 0.56, color: tint.foreground),
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

/// Small stat card: colored icon, big value, label below, optional trend.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label, this.trend, this.icon, this.accent});

  final String value;
  final String label;
  final Widget? trend;
  final IconData? icon;
  final Accent? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = accent == null ? null : accentTint(context, accent!);
    return AppCard(
      padding: const EdgeInsets.all(14),
      gradient: tint == null
          ? null
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.alphaBlend(tint.background.withValues(alpha: 0.55), c.surface), c.surface],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && accent != null) ...[IconBadge(icon!, accent!, size: 30), const SizedBox(height: 10)],
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
            child: Breathing(
              builder: (context, t) => Transform.scale(
                scale: 0.97 + 0.06 * t,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: c.mint,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: c.glow, blurRadius: 24 + 16 * t, spreadRadius: 4 * t)],
                  ),
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
            ),
          ),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 14),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            Pressable(
              child: FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ),
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
      label: flat
          ? '${l.trendSame} $comparedTo'
          : (up ? l.trendUp(rounded.abs(), comparedTo) : l.trendDown(rounded.abs(), comparedTo)),
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          if (!flat) Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 14, color: color),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: flat ? c.textSecondary : color),
          ),
          Text(' $comparedTo', style: TextStyle(fontSize: 12, color: c.textSecondary)),
        ],
      ),
    );
  }
}
