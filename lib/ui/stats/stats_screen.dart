import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../common/charts.dart';
import '../common/components.dart';
import '../common/motion.dart';
import '../common/format.dart';
import '../routes.dart';

enum StatsView { week, month }

/// Week | Month statistics. Every view answers: how much did I complete,
/// is it getting better, and where do I slip?
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _Period {
  const _Period(this.from, this.to, this.prevFrom, this.prevTo);

  final DateTime from;
  final DateTime to;
  final DateTime prevFrom;
  final DateTime prevTo;
}

class _StatsScreenState extends State<StatsScreen> {
  StatsView _view = StatsView.week;
  DateTime? _anchor;
  String? _habitId;

  _Period _period(DateTime anchor, int firstWeekday) {
    if (_view == StatsView.week) {
      final from = startOfWeek(anchor, firstWeekday);
      return _Period(from, addDays(from, 6), addDays(from, -7), addDays(from, -1));
    }
    final from = startOfMonth(anchor);
    final prevFrom = DateTime(from.year, from.month - 1);
    return _Period(from, endOfMonth(from), prevFrom, endOfMonth(prevFrom));
  }

  void _shift(int direction, _Period p) => setState(() {
    _anchor = _view == StatsView.week
        ? addDays(p.from, 7 * direction)
        : DateTime(p.from.year, p.from.month + direction);
  });

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l = context.l10n;
    final c = context.colors;
    final today = store.today;
    final firstWeekday = context.settings.firstWeekday;
    final stats = store.stats;

    if (store.habits.isEmpty) {
      return SafeArea(
        child: Center(
          child: EmptyState(
            icon: Icons.insights_rounded,
            title: l.statsEmptyTitle,
            message: l.statsEmptyNoHabits,
            actionLabel: l.addFirstHabit,
            onAction: () => openHabitForm(context),
          ),
        ),
      );
    }

    if (_habitId != null && store.habitById(_habitId!) == null) _habitId = null;
    final habits = _habitId == null ? store.habits : [store.habitById(_habitId!)!];
    final p = _period(_anchor ?? today, firstWeekday);
    final isCurrent = !p.to.isBefore(today);
    final cur = stats.summarize(habits, p.from, p.to);
    // While a period is still running, compare with the same number of days
    // of the previous period, so a half-finished week is not compared to a full one.
    final elapsed = daysBetween(p.from, today);
    final prevEnd = isCurrent && addDays(p.prevFrom, elapsed).isBefore(p.prevTo)
        ? addDays(p.prevFrom, elapsed)
        : p.prevTo;
    final prev = stats.summarize(habits, p.prevFrom, prevEnd);
    final effectiveTo = isCurrent ? today : p.to;
    final isWeek = _view == StatsView.week;
    final compared = isWeek ? l.vsLastWeek : l.vsLastMonth;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: staggered([
          Semantics(header: true, child: Text(l.tabStats, style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 16),
          PillSegmented<StatsView>(
            value: _view,
            options: [(StatsView.week, l.week), (StatsView.month, l.month)],
            onChanged: (v) => setState(() => _view = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: isWeek ? l.previousWeek : l.previousMonth,
                onPressed: () => _shift(-1, p),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: context.motion(Motion.base),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    isWeek
                        ? '${formatShortDate(context, p.from)} – ${formatShortDate(context, p.to)}'
                        : formatMonthYear(context, p.from),
                    key: ValueKey((_view, p.from)),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                tooltip: isWeek ? l.nextWeek : l.nextMonth,
                onPressed: isCurrent ? null : () => _shift(1, p),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          if (!isCurrent)
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _anchor = null),
                icon: const Icon(Icons.today_rounded, size: 18),
                label: Text(l.jumpToToday),
              ),
            ),
          const SizedBox(height: 4),
          _HabitFilter(selected: _habitId, onChanged: (id) => setState(() => _habitId = id)),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: AnimatedSwitcher(
              duration: context.motion(Motion.base + 60),
              switchInCurve: Motion.settle,
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              layoutBuilder: (current, previous) =>
                  Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
              child: KeyedSubtree(
                key: ValueKey((_view, p.from, _habitId)),
                child: cur.scheduled == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 40, color: c.primary),
                            const SizedBox(height: 8),
                            Text(
                              l.statsEmptyPeriod,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: c.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : isWeek
                    ? _WeekChart(summary: cur, habits: habits)
                    : _MonthHeatmap(summary: cur, habits: habits, month: p.from),
              ),
            ),
          ),
          if (_insight(context, stats, habits, cur, prev, p, effectiveTo) case final text?) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentTint(context, Accent.amber).background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  IconBadge(Icons.lightbulb_rounded, Accent.amber, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(color: accentTint(context, Accent.amber).foreground, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SectionLabel(l.summary),
          _SummaryGrid(
            tiles: isWeek
                ? [
                    _tile(formatPercent(cur.rate), l.completionRate, _ppDelta(cur.rate, prev.rate), compared, (Icons.donut_large_rounded, Accent.sky)),
                    _tile('${cur.done}', l.habitsCompleted, _relDelta(cur.done, prev.done), compared, (Icons.task_alt_rounded, Accent.violet)),
                    _tile(
                      cur.bestDay == null ? '–' : weekdayLong(context, cur.bestDay!.day.weekday),
                      l.bestDay,
                      null,
                      compared,
                      (Icons.emoji_events_rounded, Accent.rose),
                    ),
                    _tile(
                      l.daysCount(habits.map(stats.currentStreak).fold(0, (a, b) => a > b ? a : b)),
                      l.currentStreak,
                      null,
                      compared,
                      (Icons.local_fire_department_rounded, Accent.coral),
                    ),
                  ]
                : [
                    _tile(formatPercent(cur.rate), l.completionRate, _ppDelta(cur.rate, prev.rate), compared, (Icons.donut_large_rounded, Accent.sky)),
                    _tile('${cur.perfectDays}', l.perfectDays, _relDelta(cur.perfectDays, prev.perfectDays), compared, (Icons.star_rounded, Accent.amber)),
                    _tile(
                      l.daysCount(
                        habits
                            .map((h) => stats.bestStreak(h, from: p.from, to: effectiveTo))
                            .fold(0, (a, b) => a > b ? a : b),
                      ),
                      l.longestStreak,
                      null,
                      compared,
                      (Icons.local_fire_department_rounded, Accent.coral),
                    ),
                    _tile('${cur.done}', l.totalCheckIns, _relDelta(cur.done, prev.done), compared, (Icons.task_alt_rounded, Accent.violet)),
                  ],
          ),
          SectionLabel(l.byHabit),
          for (final s in _ranked(stats, store.habits, p.from, p.to))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HabitRow(stat: s),
            ),
        ]),
      ),
    );
  }

  StatTile _tile(String value, String label, double? delta, String compared, (IconData, Accent) look) => StatTile(
    value: value,
    label: label,
    icon: look.$1,
    accent: look.$2,
    trend: delta == null ? null : TrendBadge(delta: delta, comparedTo: compared),
  );

  /// Percentage-point change between two rates.
  double? _ppDelta(double? a, double? b) => (a == null || b == null) ? null : (a - b) * 100;

  /// Relative change between two counts, in percent.
  double? _relDelta(int a, int b) => b == 0 ? null : (a - b) / b * 100;

  List<HabitPeriodStat> _ranked(Stats stats, List<Habit> habits, DateTime from, DateTime to) {
    final list = [for (final h in habits) stats.habitStat(h, from, to)];
    list.sort((a, b) => (b.rate ?? -1).compareTo(a.rate ?? -1));
    return list;
  }

  String? _insight(
    BuildContext context,
    Stats stats,
    List<Habit> habits,
    PeriodSummary cur,
    PeriodSummary prev,
    _Period p,
    DateTime effectiveTo,
  ) {
    final l = context.l10n;
    if (cur.scheduled == 0) return null;
    final diff = _ppDelta(cur.rate, prev.rate)?.round();
    final isWeek = _view == StatsView.week;
    if (diff != null && diff > 0) return isWeek ? l.insightBetterWeek(diff) : l.insightBetterMonth(diff);
    // Look at a longer window so the weekday pattern is meaningful.
    final hardest = stats.hardestWeekday(habits, addDays(effectiveTo, -55), effectiveTo);
    if (hardest != null) return l.insightHardestDay(weekdayLong(context, hardest));
    if (diff != null && diff == 0) return l.insightSteady;
    return l.insightKeepGoing;
  }
}

class _HabitFilter extends StatelessWidget {
  const _HabitFilter({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final habits = context.store.habits;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: Text(context.l10n.allHabits),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          for (final h in habits)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: ChoiceChip(
                avatar: HabitAvatar.of(h, size: 24),
                label: Text(h.name),
                selected: selected == h.id,
                onSelected: (_) => onChanged(selected == h.id ? null : h.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.summary, required this.habits});

  final PeriodSummary summary;
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final today = context.store.today;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BarChart(
          height: 190,
          bars: [
            for (final d in summary.days)
              BarDatum(
                label: weekdayNarrow(context, d.day.weekday),
                value: d.rate,
                highlight: d.day == today,
                semanticLabel: l.dayBarSemantics(formatLongDate(context, d.day), d.done, d.scheduled),
              ),
          ],
          onTap: (i) => showDayDetails(context, summary.days[i].day, habits),
        ),
        const SizedBox(height: 8),
        Text(l.chartCaptionDaily, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
      ],
    );
  }
}

class _MonthHeatmap extends StatelessWidget {
  const _MonthHeatmap({required this.summary, required this.habits, required this.month});

  final PeriodSummary summary;
  final List<Habit> habits;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final byDay = {for (final d in summary.days) d.day: d};
    return Column(
      children: [
        MonthCalendar(
          month: month,
          firstWeekday: context.settings.firstWeekday,
          onTap: (d) => showDayDetails(context, d, habits),
          cellFor: (d) {
            final agg = byDay[d];
            final rate = agg?.rate;
            final label = formatLongDate(context, d);
            if (rate == null) {
              return CalendarCell(
                fill: Colors.transparent,
                textColor: c.textSecondary.withValues(alpha: 0.55),
                semanticLabel: '$label: ${l.noData}',
                enabled: false,
              );
            }
            return CalendarCell(
              fill: c.heat(0.12 + rate * 0.88),
              textColor: c.onHeat(0.12 + rate * 0.88),
              marked: agg!.perfect,
              semanticLabel: l.dayBarSemantics(label, agg.done, agg.scheduled),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(l.less, style: TextStyle(fontSize: 12, color: c.textSecondary)),
            const SizedBox(width: 6),
            for (final v in const [0.12, 0.34, 0.56, 0.78, 1.0])
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: c.heat(v), borderRadius: BorderRadius.circular(4)),
              ),
            const SizedBox(width: 2),
            Text(l.more, style: TextStyle(fontSize: 12, color: c.textSecondary)),
            const Spacer(),
            Icon(Icons.check_rounded, size: 14, color: c.textSecondary),
            const SizedBox(width: 2),
            Flexible(
              child: Text(l.perfectDay, style: TextStyle(fontSize: 12, color: c.textSecondary)),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: 10),
                  Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.stat});

  final HabitPeriodStat stat;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rate = stat.rate;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => openHabitDetail(context, stat.habit.id),
      child: Row(
        children: [
          HabitAvatar.of(stat.habit, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.habit.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                AnimatedProgressBar(value: rate ?? 0, color: habitTint(context, stat.habit.colorIndex).foreground),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: rate == null
                ? Text(
                    formatPercent(rate),
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary, fontSize: 16),
                  )
                : AnimatedNumber(
                    value: rate,
                    format: (v) => formatPercent(v.toDouble()),
                    style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with exact numbers for one day and which habits were done.
Future<void> showDayDetails(BuildContext context, DateTime day, List<Habit> habits) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final store = ctx.store;
      final stats = store.stats;
      final l = ctx.l10n;
      final c = ctx.colors;
      final scheduled = habits.where((h) => h.isScheduledOn(day)).toList();
      final agg = stats.summarize(habits, day, day).days.first;
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(formatLongDate(ctx, day), style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(l.doneOfScheduled(agg.done, agg.scheduled), style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: 12),
            if (scheduled.isEmpty) Text(l.nothingScheduled, style: TextStyle(color: c.textSecondary)),
            for (final h in scheduled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: HabitAvatar.of(h, size: 40),
                title: Text(h.name),
                trailing: _statusText(ctx, stats.status(h, day)),
              ),
          ],
        ),
      );
    },
  );
}

Widget _statusText(BuildContext context, DayStatus s) {
  final c = context.colors;
  final l = context.l10n;
  final (String text, IconData icon, Color color) = switch (s) {
    DayStatus.done => (l.statusDone, Icons.check_circle_rounded, c.primary),
    DayStatus.skipped => (l.statusSkipped, Icons.skip_next_rounded, c.textSecondary),
    DayStatus.partial => (l.statusPartial, Icons.timelapse_rounded, c.textSecondary),
    DayStatus.pending => (l.statusPending, Icons.radio_button_unchecked_rounded, c.textSecondary),
    _ => (l.statusNotDone, Icons.radio_button_unchecked_rounded, c.textSecondary),
  };
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
