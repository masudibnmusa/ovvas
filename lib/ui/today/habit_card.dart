import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../common/components.dart';
import '../common/dialogs.dart';
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
      color: done ? Color.alphaBlend(c.mint.withValues(alpha: 0.45), c.surface) : null,
      onTap: () => openHabitDetail(context, habit.id),
      onLongPress: () => _quickActions(context),
      child: Row(
        children: [
          HabitAvatar.of(habit),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    subtitle,
                    if (done)
                      Text(l.doneLabel, style: TextStyle(fontSize: 13, color: c.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
                if (habit.isMeasured && !skipped) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: (value / habit.target).clamp(0.0, 1.0), minHeight: 6),
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
          ..showSnackBar(SnackBar(
            content: Text(l.habitArchived(habit.name)),
            action: SnackBarAction(label: l.undo, onPressed: () => store.setArchived(habit.id, false)),
          ));
    }
  }
}

enum _Action { note, skip, edit, archive }

class _Subtle extends StatelessWidget {
  const _Subtle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 13, color: context.colors.textSecondary));
}

/// Unit shown next to a Count or Time value.
String unitLabel(BuildContext context, Habit h) =>
    h.goalType == GoalType.time ? context.l10n.unitMinutes : h.unit;

enum CheckVisual { empty, done, add, skipped }

/// 56dp round check button with a gentle fill animation.
class CheckButton extends StatelessWidget {
  const CheckButton({
    super.key,
    required this.visual,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 56,
  });

  final CheckVisual visual;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final duration = context.motion(240);
    final (Color fill, Border? border, IconData? icon, Color iconColor) = switch (visual) {
      CheckVisual.done => (c.primary, null, Icons.check_rounded, c.onPrimary),
      CheckVisual.add => (c.mint, null, Icons.add_rounded, c.onMint),
      CheckVisual.skipped => (Colors.transparent, Border.all(color: c.border, width: 2), Icons.skip_next_rounded, c.textSecondary),
      CheckVisual.empty => (Colors.transparent, Border.all(color: c.textSecondary.withValues(alpha: 0.7), width: 2), null, c.textSecondary),
    };
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
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
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, color: fill, border: border),
              child: AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(icon, key: ValueKey(visual), color: iconColor, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
