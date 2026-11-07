import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../common/charts.dart';
import '../common/components.dart';
import '../common/format.dart';
import '../routes.dart';
import 'habit_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  /// The day being viewed. Null means today.
  DateTime? _selected;

  void _select(DateTime day) => setState(() => _selected = day == context.store.today ? null : day);

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final settings = context.settings;
    final l = context.l10n;
    final c = context.colors;
    final today = store.today;
    final day = _selected ?? today;
    final stats = store.stats;
    final habits = store.habitsOn(day);
    final statuses = [for (final h in habits) stats.status(h, day)];
    final active = statuses.where((s) => s != DayStatus.skipped).length;
    final done = statuses.where((s) => s == DayStatus.done).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          _Header(name: settings.userName, now: store.now()),
          const SizedBox(height: 12),
          const Align(alignment: AlignmentDirectional.centerStart, child: SyncChip()),
          const SizedBox(height: 16),
          WeekStrip(selected: day, today: today, firstWeekday: settings.firstWeekday, onSelected: _select),
          if (day != today) ...[
            const SizedBox(height: 12),
            _PastDayBanner(day: day, onBack: () => _select(today)),
          ],
          if (store.habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: EmptyState(
                title: l.emptyTodayTitle,
                message: l.emptyTodayBody,
                actionLabel: l.addFirstHabit,
                onAction: () => openHabitForm(context),
              ),
            )
          else ...[
            const SizedBox(height: 24),
            Center(
              child: Semantics(
                label: l.ringSemantics(done, active),
                excludeSemantics: true,
                child: ProgressRing(
                  progress: active == 0 ? 0 : done / active,
                  size: 164,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.doneOfTotal(done, active),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: c.primary),
                      ),
                      Text(l.completedLabel, style: TextStyle(color: c.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
            SectionLabel(l.yourHabits),
            if (habits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l.nothingScheduled, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
              )
            else
              for (final h in habits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HabitCard(key: ValueKey(h.id), habit: h, day: day),
                ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.now});

  final String name;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final greeting = now.hour < 12
        ? l.greetingMorning(name)
        : now.hour < 17
            ? l.greetingAfternoon(name)
            : l.greetingEvening(name);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(greeting, style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: 4),
              Text(formatLongDate(context, now), style: TextStyle(color: c.textSecondary, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ExcludeSemantics(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: c.mint,
            child: Text(
              name.isEmpty ? '🙂' : name.characters.first.toUpperCase(),
              style: TextStyle(color: c.onMint, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Backed up just now" status chip.
class SyncChip extends StatelessWidget {
  const SyncChip({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l = context.l10n;
    final c = context.colors;
    final last = store.lastBackup;
    final now = store.now();

    final (IconData icon, String label, Color bg, Color fg) = switch (last) {
      _ when !store.signedIn => (Icons.phone_android_rounded, l.savedOnPhoneOnly, c.surfaceMuted, c.textSecondary),
      null => (Icons.cloud_queue_rounded, l.waitingForInternet, c.surfaceMuted, c.textSecondary),
      final t when now.difference(t).inDays >= 3 => (Icons.cloud_off_rounded, l.backupNeedsAttention, c.surfaceMuted, c.streak),
      final t when now.difference(t).inMinutes < 2 => (Icons.cloud_done_rounded, l.backedUpJustNow, c.mint, c.onMint),
      final t => (Icons.cloud_done_rounded, l.backedUpAt(formatTime(context, _timeOf(t))), c.mint, c.onMint),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

/// Seven days of the current week. Swipe to move between weeks.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.firstWeekday,
    required this.onSelected,
  });

  final DateTime selected;
  final DateTime today;
  final int firstWeekday;
  final ValueChanged<DateTime> onSelected;

  /// Check-ins can be edited up to a year back.
  static const maxDaysBack = 365;

  bool _selectable(DateTime d) => !d.isAfter(today) && daysBetween(d, today) <= maxDaysBack;

  void _swipe(double velocity) {
    final target = addDays(selected, velocity > 0 ? -7 : 7);
    if (_selectable(target)) {
      onSelected(target);
    } else if (velocity < 0) {
      onSelected(today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = startOfWeek(selected, firstWeekday);
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() > 200) _swipe(v);
      },
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Builder(builder: (context) {
              final d = addDays(start, i);
              final isSelected = d == selected;
              final isToday = d == today;
              final enabled = _selectable(d);
              final numberColor = isSelected
                  ? c.onPrimary
                  : !enabled
                      ? c.textSecondary.withValues(alpha: 0.5)
                      : isToday
                          ? c.primary
                          : c.textPrimary;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  enabled: enabled,
                  label: formatLongDate(context, d),
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isSelected ? c.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: enabled ? () => onSelected(d) : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                weekdayNarrow(context, d.weekday),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? c.onPrimary : c.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: numberColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _PastDayBanner extends StatelessWidget {
  const _PastDayBanner({required this.day, required this.onBack});

  final DateTime day;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
      decoration: BoxDecoration(color: c.mint, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 18, color: c.onMint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.editingDay(formatLongDate(context, day)),
              style: TextStyle(color: c.onMint, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(onPressed: onBack, child: Text(l.backToToday)),
        ],
      ),
    );
  }
}

ReminderTime _timeOf(DateTime t) => ReminderTime(t.hour, t.minute);
