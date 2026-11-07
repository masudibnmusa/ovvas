import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../common/charts.dart';
import '../common/components.dart';
import '../common/dialogs.dart';
import '../common/format.dart';
import '../routes.dart';
import '../today/habit_card.dart' show unitLabel;
import '../today/today_screen.dart' show WeekStrip;

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

enum _Menu { archive, delete }

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime? _month;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l = context.l10n;
    final c = context.colors;
    final habit = store.habitById(widget.habitId);
    if (habit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.habitNotFound)),
      );
    }

    final stats = store.stats;
    final today = store.today;
    final month = _month ?? startOfMonth(today);
    final current = stats.currentStreak(habit);
    final best = stats.bestStreak(habit);
    final overall = stats.habitStat(habit, habit.startDate, today);
    final bestDay = stats.bestWeekday([habit], habit.startDate, today);
    final notes = store.notesFor(habit.id);
    final canGoNext = startOfMonth(today).isAfter(month);
    final canGoBack = !startOfMonth(habit.startDate).isAfter(addDays(month, -1));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.editHabit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => openHabitForm(context, habit: habit),
          ),
          PopupMenuButton<_Menu>(
            tooltip: l.moreActions,
            onSelected: (m) => _onMenu(m, habit),
            itemBuilder: (_) => [
              PopupMenuItem(value: _Menu.archive, child: Text(habit.archived ? l.restoreHabit : l.archiveHabit)),
              PopupMenuItem(
                value: _Menu.delete,
                child: Text(l.deleteHabit, style: TextStyle(color: c.danger)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Row(
            children: [
              HabitAvatar.of(habit, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(habit.name, style: Theme.of(context).textTheme.headlineSmall)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StreakLabel(current),
                        Text('· ${l.bestStreak(best)}', style: TextStyle(color: c.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (habit.isMeasured) ...[
            SectionLabel(l.todayLabel),
            CountStepper(
              value: store.entry(habit.id, today)?.value ?? 0,
              step: habit.step,
              unit: l.goalOf(habit.target, unitLabel(context, habit)),
              onChanged: (v) {
                context.haptic(soft: true);
                store.setValue(habit, today, v);
              },
            ),
          ],
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatTile(value: formatPercent(overall.rate), label: l.completionRate),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(value: '${overall.done}', label: l.checkIns),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(value: bestDay == null ? '–' : weekdayShort(context, bestDay), label: l.bestDay),
                ),
              ],
            ),
          ),
          SectionLabel(
            formatMonthYear(context, month),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l.previousMonth,
                  onPressed: canGoBack ? () => setState(() => _month = DateTime(month.year, month.month - 1)) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  tooltip: l.nextMonth,
                  onPressed: canGoNext ? () => setState(() => _month = DateTime(month.year, month.month + 1)) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 16, bottom: 4),
          ),
          AppCard(
            child: Column(
              children: [
                MonthCalendar(
                  month: month,
                  firstWeekday: context.settings.firstWeekday,
                  cellFor: (d) => _cell(context, habit, stats, d),
                  onTap: (d) => _editDay(habit, d),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    LegendItem(color: c.primary, label: l.statusDone),
                    LegendItem(color: c.heat(0.35), label: l.statusPartial),
                    LegendItem(color: Colors.transparent, border: c.border, label: l.statusSkipped),
                    LegendItem(color: c.surfaceMuted, label: l.statusMissed),
                  ],
                ),
              ],
            ),
          ),
          SectionLabel(l.last8Weeks),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EightWeeks(habit: habit),
                const SizedBox(height: 8),
                Text(l.chartCaptionWeekly, style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          SectionLabel(l.notes),
          if (habit.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(child: Text(habit.note)),
            ),
          if (notes.isEmpty && habit.note.isEmpty)
            Text(l.noNotesYet, style: TextStyle(color: c.textSecondary))
          else
            for (final (day, text) in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatLongDate(context, day),
                        style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(text),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => openHabitForm(context, habit: habit),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l.editHabit),
            ),
          ),
        ],
      ),
    );
  }

  CalendarCell _cell(BuildContext context, Habit habit, Stats stats, DateTime d) {
    final c = context.colors;
    final l = context.l10n;
    final status = stats.status(habit, d);
    final date = formatLongDate(context, d);
    final editable =
        !d.isAfter(stats.today) && daysBetween(d, stats.today) <= WeekStrip.maxDaysBack && habit.isScheduledOn(d);
    return switch (status) {
      DayStatus.done => CalendarCell(
        fill: c.primary,
        textColor: c.onPrimary,
        marked: true,
        semanticLabel: '$date: ${l.statusDone}',
      ),
      DayStatus.partial => CalendarCell(
        fill: c.heat(0.35),
        textColor: c.textPrimary,
        semanticLabel: '$date: ${l.statusPartial}',
        enabled: editable,
      ),
      DayStatus.skipped => CalendarCell(
        fill: Colors.transparent,
        border: c.border,
        textColor: c.textSecondary,
        semanticLabel: '$date: ${l.statusSkipped}',
        enabled: editable,
      ),
      DayStatus.missed => CalendarCell(
        fill: c.surfaceMuted,
        textColor: c.textPrimary,
        semanticLabel: '$date: ${l.statusMissed}',
        enabled: editable,
      ),
      DayStatus.pending => CalendarCell(
        fill: Colors.transparent,
        border: c.primary,
        textColor: c.primary,
        semanticLabel: '$date: ${l.statusPending}',
        enabled: editable,
      ),
      DayStatus.notScheduled || DayStatus.future => CalendarCell(
        fill: Colors.transparent,
        textColor: c.textSecondary.withValues(alpha: 0.55),
        semanticLabel: '$date: ${l.statusNotScheduled}',
        enabled: false,
      ),
    };
  }

  Future<void> _editDay(Habit habit, DateTime day) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DayEditorSheet(habitId: habit.id, day: day),
    );
  }

  Future<void> _onMenu(_Menu m, Habit habit) async {
    final store = context.store;
    final l = context.l10n;
    switch (m) {
      case _Menu.archive:
        store.setArchived(habit.id, !habit.archived);
        context.showSnack(habit.archived ? l.habitRestored(habit.name) : l.habitArchived(habit.name));
        if (!habit.archived) Navigator.pop(context);
      case _Menu.delete:
        final ok = await confirmAction(
          context,
          title: l.deleteHabitTitle(habit.name),
          message: l.deleteHabitBody,
          confirmLabel: l.delete,
          destructive: true,
        );
        if (!ok || !mounted) return;
        Navigator.pop(context);
        store.deleteHabit(habit.id);
    }
  }
}

class _EightWeeks extends StatelessWidget {
  const _EightWeeks({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final stats = store.stats;
    final l = context.l10n;
    final thisWeek = startOfWeek(store.today, context.settings.firstWeekday);
    final bars = <BarDatum>[];
    for (var i = 7; i >= 0; i--) {
      final from = addDays(thisWeek, -7 * i);
      final s = stats.habitStat(habit, from, addDays(from, 6));
      bars.add(
        BarDatum(
          label: formatNumericDate(context, from),
          value: s.rate,
          highlight: i == 0,
          semanticLabel: l.weekBarSemantics(formatShortDate(context, from), s.done, s.scheduled),
        ),
      );
    }
    return BarChart(bars: bars, height: 170, barWidth: 16);
  }
}

/// Edit one day's status from the calendar.
class _DayEditorSheet extends StatelessWidget {
  const _DayEditorSheet({required this.habitId, required this.day});

  final String habitId;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l = context.l10n;
    final habit = store.habitById(habitId);
    if (habit == null) return const SizedBox.shrink();
    final entry = store.entry(habitId, day) ?? const DayEntry();
    final status = store.stats.status(habit, day);
    final current = switch (status) {
      DayStatus.done => DayStatus.done,
      DayStatus.skipped => DayStatus.skipped,
      _ => DayStatus.missed,
    };

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatLongDate(context, day), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(habit.name, style: TextStyle(color: context.colors.textSecondary)),
            const SizedBox(height: 16),
            if (habit.isMeasured) ...[
              CountStepper(
                value: entry.value,
                step: habit.step,
                unit: l.goalOf(habit.target, unitLabel(context, habit)),
                onChanged: (v) => store.setValue(habit, day, v),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.skipDay),
                subtitle: Text(l.skipHint),
                value: entry.skipped,
                onChanged: (v) => store.setSkipped(habit, day, v),
              ),
            ] else
              PillSegmented<DayStatus>(
                value: current,
                options: [
                  (DayStatus.done, l.statusDone),
                  (DayStatus.missed, l.statusNotDone),
                  (DayStatus.skipped, l.statusSkipped),
                ],
                onChanged: (s) {
                  switch (s) {
                    case DayStatus.done:
                      store.setValue(habit, day, habit.target);
                    case DayStatus.skipped:
                      store.setSkipped(habit, day, true);
                    default:
                      store.setValue(habit, day, 0);
                  }
                },
              ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final note = await askText(
                  context,
                  title: l.noteFor(habit.name),
                  initial: entry.note,
                  hint: l.noteHint,
                );
                if (note != null) store.setNote(habit, day, note);
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(entry.note.isEmpty ? l.addNote : l.editNote),
            ),
          ],
        ),
      ),
    );
  }
}
