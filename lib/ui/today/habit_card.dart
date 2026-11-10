import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../common/charts.dart';
import '../common/components.dart';
import '../common/dialogs.dart';
import '../common/motion.dart';
import '../routes.dart';

const _milestones = {7, 30, 100, 365};

/// One habit row on Today: icon, name, streak, and a large check button.
class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit, required this.day});

  final Habit habit;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final stats = store.stats;
    final l = context.l10n;
    final c = context.colors;
    final status = stats.status(habit, day);
    final done = status == DayStatus.done;
    final skipped = status == DayStatus.skipped;
    final value = store.entry(habit.id, day)?.value ?? 0;
    final streak = stats.currentStreak(habit);

    final Widget subtitle;
    if (skipped) {
      subtitle = _Subtle(l.skippedForDay);
    } else if (streak > 0) {
      subtitle = StreakLabel(streak, fontSize: 13);
    } else if (stats.bestStreak(habit) > 0) {
      subtitle = _Subtle(l.readyToStartAgain);
    } else {
      subtitle = _Subtle(l.firstStepHint);
    }

    final visual = skipped
        ? CheckVisual.skipped
        : done
        ? CheckVisual.done
        : habit.isMeasured
        ? CheckVisual.add
        : CheckVisual.empty;

    final checkLabel = switch (visual) {
      CheckVisual.done => l.checkUndo(habit.name),
      CheckVisual.add => l.checkAdd(habit.step, habit.name),
      CheckVisual.skipped => l.checkUnskip(habit.name),
      CheckVisual.empty => l.checkDo(habit.name),
    };

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      color: done
          ? Color.alphaBlend(habitTint(context, habit.colorIndex).background.withValues(alpha: 0.55), c.surface)
          : null,
      onTap: () => openHabitDetail(context, habit.id),
      onLongPress: () => _quickActions(context),
      child: Row(
        children: [
          HabitAvatar.of(habit, hero: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    subtitle,
                    AnimatedSwitcher(
                      duration: context.motion(Motion.base),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: anim,
                          alignment: AlignmentDirectional.centerStart.resolve(Directionality.of(context)),
                          child: child,
                        ),
                      ),
                      child: done
                          ? Container(
                              key: const ValueKey('done'),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: habitTint(context, habit.colorIndex).background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l.doneLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: habitTint(context, habit.colorIndex).foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('open')),
                    ),
                  ],
                ),
                if (habit.isMeasured && !skipped) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedProgressBar(
                          value: value / habit.target,
                          color: habitTint(context, habit.colorIndex).foreground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l.progressOf(value, habit.target, unitLabel(context, habit)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          CheckButton(
            visual: visual,
            colorIndex: habit.colorIndex,
            burstColors: [
              habitTint(context, habit.colorIndex).foreground,
              kHabitColors[habit.colorIndex % kHabitColors.length],
              c.streak,
              c.primary,
            ],
            semanticLabel: checkLabel,
            onPressed: () => skipped ? store.setSkipped(habit, day, false) : _check(context),
          ),
        ],
      ),
    );
  }

  void _check(BuildContext context) {
    final store = context.store;
    final wasDone = store.stats.status(habit, day) == DayStatus.done;
    final completed = store.toggle(habit, day);
    context.haptic(soft: wasDone);
    if (completed && day == store.today && context.settings.celebrations) {
      final streak = store.stats.currentStreak(habit);
      if (_milestones.contains(streak)) context.showSnack(context.l10n.milestone(streak, habit.name));
    }
  }

  Future<void> _quickActions(BuildContext context) async {
    final l = context.l10n;
    final store = context.store;
    final skipped = store.entry(habit.id, day)?.skipped ?? false;
    final action = await showModalBottomSheet<_Action>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: HabitAvatar.of(habit, size: 40),
              title: Text(habit.name, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: Text(l.addNote),
              onTap: () => Navigator.pop(ctx, _Action.note),
            ),
            ListTile(
              leading: const Icon(Icons.skip_next_rounded),
              title: Text(skipped ? l.unskipDay : l.skipDay),
              subtitle: skipped ? null : Text(l.skipHint),
              onTap: () => Navigator.pop(ctx, _Action.skip),
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: Text(l.editHabit),
              onTap: () => Navigator.pop(ctx, _Action.edit),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(l.archiveHabit),
              onTap: () => Navigator.pop(ctx, _Action.archive),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _Action.note:
        final note = await askText(
          context,
          title: l.noteFor(habit.name),
          initial: store.entry(habit.id, day)?.note ?? '',
          hint: l.noteHint,
        );
        if (note != null) store.setNote(habit, day, note);
      case _Action.skip:
        store.setSkipped(habit, day, !skipped);
      case _Action.edit:
        await openHabitForm(context, habit: habit);
      case _Action.archive:
        final messenger = ScaffoldMessenger.of(context);
        store.setArchived(habit.id, true);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l.habitArchived(habit.name)),
              action: SnackBarAction(label: l.undo, onPressed: () => store.setArchived(habit.id, false)),
            ),
          );
    }
  }
}

enum _Action { note, skip, edit, archive }

class _Subtle extends StatelessWidget {
  const _Subtle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(fontSize: 13, color: context.colors.textSecondary));
}

/// Unit shown next to a Count or Time value.
String unitLabel(BuildContext context, Habit h) => h.goalType == GoalType.time ? context.l10n.unitMinutes : h.unit;

enum CheckVisual { empty, done, add, skipped }

/// 56dp round check button with a gentle fill animation.
class CheckButton extends StatelessWidget {
  const CheckButton({
    super.key,
    required this.visual,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 56,
    this.burstColors,
    this.colorIndex,
  });

  /// Habit color for the done fill. Null uses the brand teal.
  final int? colorIndex;

  /// Confetti colors for the moment it becomes done.
  final List<Color>? burstColors;

  final CheckVisual visual;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final duration = context.motion(240);
    final solid = colorIndex == null ? null : habitSolid(context, colorIndex!);
    final doneFill = solid?.fill ?? c.primary;
    final onDone = solid?.onFill ?? c.onPrimary;
    final addTint = colorIndex == null ? HabitTint(c.mint, c.onMint) : habitTint(context, colorIndex!);
    final (Color fill, Border? border, IconData? icon, Color iconColor) = switch (visual) {
      CheckVisual.done => (doneFill, null, Icons.check_rounded, onDone),
      CheckVisual.add => (addTint.background, null, Icons.add_rounded, addTint.foreground),
      CheckVisual.skipped => (
        Colors.transparent,
        Border.all(color: c.border, width: 2),
        Icons.skip_next_rounded,
        c.textSecondary,
      ),
      CheckVisual.empty => (
        Colors.transparent,
        Border.all(color: c.textSecondary.withValues(alpha: 0.7), width: 2),
        null,
        c.textSecondary,
      ),
    };
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Burst(
        trigger: visual == CheckVisual.done ? true : null,
        colors: burstColors ?? [c.primary, c.streak],
        child: SizedBox.square(
          dimension: size,
          child: Material(
            type: MaterialType.transparency,
            child: InkResponse(
              onTap: onPressed,
              radius: size / 2,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutBack,
                margin: EdgeInsets.all(visual == CheckVisual.done ? 2 : 4),
                // Every state keeps the same border, gradient and shadow shape and
                // only changes colors, so the springy curve can overshoot safely.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: border ?? Border.all(color: Colors.transparent, width: 2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: visual == CheckVisual.done
                        ? [Color.lerp(doneFill, Colors.white, 0.2)!, doneFill]
                        : [fill, fill],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: visual == CheckVisual.done ? doneFill.withValues(alpha: 0.35) : Colors.transparent,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: duration,
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween(begin: -0.15, end: 0.0).animate(anim),
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Icon(icon, key: ValueKey(visual), color: iconColor, size: 28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
