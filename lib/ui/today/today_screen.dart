import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import '../common/charts.dart';
import '../common/components.dart';
import '../../core/theme/habit_palette.dart';
import '../common/format.dart';
import '../common/motion.dart';
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

  void _select(DateTime day) {
    final next = day == context.store.today ? null : day;
    if (next == _selected) return;
    context.haptic(soft: true);
    setState(() => _selected = next);
  }

  /// Share of active habits done on [day], or null when nothing is due.
  double? _progressOn(DateTime day) {
    final store = context.store;
    var active = 0, done = 0;
    for (final h in store.habitsOn(day)) {
      final s = store.stats.status(h, day);
      if (s == DayStatus.skipped || s == DayStatus.future || s == DayStatus.notScheduled) continue;
      active++;
      if (s == DayStatus.done) done++;
    }
    return active == 0 ? null : done / active;
  }

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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.paddingOf(context).bottom + 96),
        children: [
          ...staggered([
            _Header(name: settings.userName, now: store.now()),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Align(alignment: AlignmentDirectional.centerStart, child: SyncChip()),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: WeekStrip(
                selected: day,
                today: today,
                firstWeekday: settings.firstWeekday,
                onSelected: _select,
                progressFor: _progressOn,
              ),
            ),
          ]),
          AnimatedSize(
            duration: context.motion(Motion.base),
            curve: Motion.enter,
            alignment: Alignment.topCenter,
            child: day == today
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _PastDayBanner(day: day, onBack: () => _select(today)),
                  ),
          ),
          if (store.habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Reveal(
                index: 3,
                child: EmptyState(
                  title: l.emptyTodayTitle,
                  message: l.emptyTodayBody,
                  actionLabel: l.addFirstHabit,
                  onAction: () => openHabitForm(context),
                ),
              ),
            )
          else
            // A fresh scope per day re-plays the card entrance when the day changes.
            RevealScope(
              key: ValueKey(day),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggered(from: 3, [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _HeroProgress(done: done, active: active, celebrate: settings.celebrations && day == today),
                  ),
                  SectionLabel(l.yourHabits),
                  if (habits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l.nothingScheduled,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.textSecondary),
                      ),
                    )
                  else
                    for (final h in habits)
                      Padding(
                        key: ValueKey(h.id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HabitCard(habit: h, day: day),
                      ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Gradient card with the day's progress ring and an encouraging line.
/// Bursts into confetti the moment the last habit is checked.
class _HeroProgress extends StatelessWidget {
  const _HeroProgress({required this.done, required this.active, required this.celebrate});

  final int done;
  final int active;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final allDone = active > 0 && done == active;
    final progress = active == 0 ? 0.0 : done / active;
    final text = Theme.of(context).textTheme;
    final heroColors = [c.onHero, c.streak, ...kHabitColors.take(4)];

    return Breathing(
      builder: (context, t) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: c.glow.withValues(alpha: allDone ? 0.55 : 0.25 + 0.1 * t),
              blurRadius: 28 + (allDone ? 12 * t : 4 * t),
              offset: const Offset(0, 12),
              spreadRadius: -6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + 0.3 * t, -1),
                end: Alignment(1, 1 - 0.3 * t),
                colors: [c.heroStart, Color.lerp(c.heroStart, c.heroEnd, 0.55)!, c.heroEnd],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Soft decorative orbs for depth.
                PositionedDirectional(
                  end: -40 + 8 * t,
                  top: -50,
                  child: _Orb(size: 150, color: c.onHero.withValues(alpha: 0.07)),
                ),
                PositionedDirectional(
                  start: 90,
                  bottom: -70 - 6 * t,
                  child: _Orb(size: 120, color: c.onHero.withValues(alpha: 0.05)),
                ),
                Row(
                  children: [
                    Burst(
                      trigger: celebrate && allDone ? done : null,
                      colors: heroColors,
                      count: 22,
                      radius: 70,
                      child: Semantics(
                        label: l.ringSemantics(done, active),
                        excludeSemantics: true,
                        child: ProgressRing(
                          progress: progress,
                          size: 112,
                          stroke: 11,
                          color: c.onHero,
                          trackColor: c.onHero.withValues(alpha: 0.18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedNumber(
                                value: done,
                                style: text.headlineMedium?.copyWith(color: c.onHero, fontSize: 30),
                              ),
                              Text(
                                '/$active',
                                style: text.titleMedium?.copyWith(color: c.onHero.withValues(alpha: 0.75)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: context.motion(Motion.slow),
                        switchInCurve: Motion.settle,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Column(
                          key: ValueKey(allDone),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (allDone)
                              Icon(Icons.auto_awesome_rounded, color: c.streak, size: 22)
                            else
                              Text(
                                l.completedLabel.toUpperCase(),
                                style: TextStyle(
                                  color: c.onHero.withValues(alpha: 0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              allDone ? l.allDoneTitle : l.habitsLeft(active - done),
                              style: text.titleLarge?.copyWith(color: c.onHero),
                            ),
                            const SizedBox(height: 4),
                            if (allDone)
                              Text(
                                l.allDoneBody,
                                style: TextStyle(color: c.onHero.withValues(alpha: 0.85), fontSize: 14),
                              )
                            else
                              _HeroBar(progress: progress),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBar extends StatelessWidget {
  const _HeroBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: AnimatedProgressBar(value: progress, color: c.onHero, track: c.onHero.withValues(alpha: 0.18)),
          ),
          const SizedBox(width: 10),
          AnimatedNumber(
            value: (progress * 100).round(),
            format: (v) => '$v%',
            style: TextStyle(color: c.onHero, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.now});

  final String name;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final (greeting, IconData icon) = now.hour < 12
        ? (l.greetingMorning(name), Icons.wb_twilight_rounded)
        : now.hour < 17
        ? (l.greetingAfternoon(name), Icons.wb_sunny_rounded)
        : (l.greetingEvening(name), Icons.nightlight_round);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: -0.6, end: 0),
                      duration: context.motion(900),
                      curve: Motion.pop,
                      builder: (context, v, child) => Transform.rotate(angle: v, child: child),
                      child: Icon(icon, size: 18, color: c.streak),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      formatLongDate(context, now),
                      style: TextStyle(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Semantics(header: true, child: Text(greeting, style: Theme.of(context).textTheme.headlineSmall)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ExcludeSemantics(
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kHabitColors[Accent.amber.colorIndex], kHabitColors[Accent.coral.colorIndex]],
              ),
              boxShadow: [
                BoxShadow(
                  color: kHabitColors[Accent.coral.colorIndex].withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              name.isEmpty ? '🙂' : name.characters.first.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
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
      final t when now.difference(t).inDays >= 3 => (
        Icons.cloud_off_rounded,
        l.backupNeedsAttention,
        c.surfaceMuted,
        c.streak,
      ),
      final t when now.difference(t).inMinutes < 2 => (Icons.cloud_done_rounded, l.backedUpJustNow, c.mint, c.onMint),
      final t => (Icons.cloud_done_rounded, l.backedUpAt(formatTime(context, _timeOf(t))), c.mint, c.onMint),
    };

    return AnimatedContainer(
      duration: context.motion(Motion.base),
      curve: Motion.enter,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: AnimatedSize(
        duration: context.motion(Motion.base),
        curve: Motion.enter,
        child: AnimatedSwitcher(
          duration: context.motion(Motion.base),
          child: Row(
            key: ValueKey(label),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seven days of the current week with a sliding selection pill and a
/// small dot showing how much of each day got done. Swipe to change weeks.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.firstWeekday,
    required this.onSelected,
    this.progressFor,
  });

  final DateTime selected;
  final DateTime today;
  final int firstWeekday;
  final ValueChanged<DateTime> onSelected;

  /// Share of habits done on a day, or null when nothing was due.
  final double? Function(DateTime day)? progressFor;

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
    final selectedIndex = daysBetween(start, selected);
    final dir = Directionality.of(context);
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() > 200) _swipe(v);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: c.cardEdge),
          boxShadow: c.raised,
        ),
        child: AnimatedSwitcher(
          duration: context.motion(Motion.slow),
          switchInCurve: Motion.settle,
          switchOutCurve: Motion.exit,
          layoutBuilder: (current, previous) => Stack(children: [...previous, ?current]),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(anim), child: child),
          ),
          child: Stack(
            key: ValueKey(start),
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  duration: context.motion(Motion.slow),
                  curve: Motion.settle,
                  alignment: AlignmentDirectional(-1 + 2 * selectedIndex / 6, 0).resolve(dir),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 7,
                    heightFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color.lerp(c.primary, Colors.white, 0.12)!, c.primary],
                          ),
                          boxShadow: [BoxShadow(color: c.glow, blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(children: [for (var i = 0; i < 7; i++) Expanded(child: _day(context, addDays(start, i)))]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _day(BuildContext context, DateTime d) {
    final c = context.colors;
    final isSelected = d == selected;
    final isToday = d == today;
    final enabled = _selectable(d);
    final progress = enabled ? progressFor?.call(d) : null;
    final numberColor = isSelected
        ? c.onPrimary
        : !enabled
        ? c.textSecondary.withValues(alpha: 0.5)
        : isToday
        ? c.primary
        : c.textPrimary;
    final dotColor = progress == null || progress == 0
        ? Colors.transparent
        : progress >= 1
        ? (isSelected ? c.onPrimary : c.primary)
        : (isSelected ? c.onPrimary.withValues(alpha: 0.6) : c.primary.withValues(alpha: 0.4));
    final fontFamily = DefaultTextStyle.of(context).style.fontFamily;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: enabled,
      label: formatLongDate(context, d),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: enabled ? () => onSelected(d) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: context.motion(Motion.base),
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? c.onPrimary.withValues(alpha: 0.85) : c.textSecondary,
                    ),
                    child: Text(weekdayNarrow(context, d.weekday)),
                  ),
                  const SizedBox(height: 6),
                  AnimatedDefaultTextStyle(
                    duration: context.motion(Motion.base),
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16,
                      fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: numberColor,
                    ),
                    child: Text('${d.day}'),
                  ),
                  const SizedBox(height: 5),
                  AnimatedContainer(
                    duration: context.motion(Motion.base),
                    curve: Motion.pop,
                    width: progress != null && progress >= 1 ? 14 : 5,
                    height: 5,
                    decoration: BoxDecoration(color: dotColor, borderRadius: BorderRadius.circular(3)),
                  ),
                ],
              ),
            ),
          ),
        ),
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
