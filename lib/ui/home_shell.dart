import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../core/theme/habit_palette.dart';
import 'common/motion.dart';
import 'routes.dart';
import 'settings/settings_screen.dart';
import 'stats/stats_screen.dart';
import 'today/today_screen.dart';
import 'widgets/widgets_screen.dart';

/// Floating bottom bar with four labeled tabs. Add habit lives on Today only.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  int _index = 0;

  /// Tabs are built on first visit, so their entrance plays when seen.
  final _visited = <int>{0};
  late final AnimationController _fade = AnimationController(vsync: this, value: 1);

  void _go(int i) {
    if (i == _index) return;
    context.haptic(soft: true);
    setState(() {
      _index = i;
      _visited.add(i);
    });
    final d = context.motion(Motion.base + 60);
    if (d == Duration.zero) return;
    _fade
      ..duration = d
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final showFab = _index == 0 && context.store.habits.isNotEmpty;
    final t = CurvedAnimation(parent: _fade, curve: Motion.settle);
    return Scaffold(
      extendBody: true,
      body: FadeTransition(
        opacity: t,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(t),
          child: IndexedStack(
            index: _index,
            children: [
              for (final (i, tab) in const [TodayScreen(), StatsScreen(), WidgetsScreen(), SettingsScreen()].indexed)
                _visited.contains(i) ? RevealScope(child: tab) : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
      floatingActionButton: ExcludeSemantics(
        excluding: !showFab,
        child: AnimatedScale(
          scale: showFab ? 1 : 0,
          duration: context.motion(Motion.base),
          curve: showFab ? Motion.pop : Motion.exit,
          child: Pressable(
            scale: 0.9,
            child: FloatingActionButton.extended(
              tooltip: l.addHabit,
              onPressed: showFab ? () => openHabitForm(context) : null,
              icon: const Icon(Icons.add_rounded, size: 26),
              label: Text(l.addHabit),
            ),
          ),
        ),
      ),
      bottomNavigationBar: OvvasNavBar(
        index: _index,
        onSelected: _go,
        items: [
          (Icons.check_circle_outline_rounded, Icons.check_circle_rounded, l.tabToday),
          (Icons.insights_outlined, Icons.insights_rounded, l.tabStats),
          (Icons.widgets_outlined, Icons.widgets_rounded, l.tabWidgets),
          (Icons.settings_outlined, Icons.settings_rounded, l.tabSettings),
        ],
      ),
    );
  }
}

/// Frosted pill bar that floats above content. A soft indicator slides to
/// the selected tab and its icon pops.
class OvvasNavBar extends StatelessWidget {
  const OvvasNavBar({super.key, required this.index, required this.onSelected, required this.items});

  final int index;
  final ValueChanged<int> onSelected;
  final List<(IconData, IconData, String)> items;

  /// Each tab has its own color: Today sky, Stats violet, Widgets coral,
  /// Settings amber.
  static const accents = [Accent.sky, Accent.violet, Accent.coral, Accent.amber];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = items.length;
    final tint = accentTint(context, accents[index % accents.length]);
    final radius = BorderRadius.circular(30);
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [BoxShadow(color: c.shadow.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 70,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.surface.withValues(alpha: 0.82),
                borderRadius: radius,
                border: Border.all(color: c.border.withValues(alpha: 0.7)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedAlign(
                      duration: context.motion(Motion.slow),
                      curve: Motion.settle,
                      alignment: AlignmentDirectional(-1 + 2 * index / (n - 1), 0).resolve(Directionality.of(context)),
                      child: FractionallySizedBox(
                        widthFactor: 1 / n,
                        child: AnimatedContainer(
                          duration: context.motion(Motion.slow),
                          curve: Motion.enter,
                          decoration: BoxDecoration(color: tint.background, borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < n; i++)
                        Expanded(
                          child: _NavItem(
                            icon: items[i].$1,
                            selectedIcon: items[i].$2,
                            label: items[i].$3,
                            selected: i == index,
                            accent: accents[i % accents.length],
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final Accent accent;

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? accentTint(context, accent).foreground : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: context.motion(Motion.base),
                curve: Motion.pop,
                child: AnimatedSwitcher(
                  duration: context.motion(Motion.quick),
                  child: Icon(selected ? selectedIcon : icon, key: ValueKey(selected), color: fg, size: 24),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: context.motion(Motion.base),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? c.textPrimary : c.textSecondary,
                  fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
