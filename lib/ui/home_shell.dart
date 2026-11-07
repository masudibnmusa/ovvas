import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import 'routes.dart';
import 'settings/settings_screen.dart';
import 'stats/stats_screen.dart';
import 'today/today_screen.dart';
import 'widgets/widgets_screen.dart';

/// Bottom bar with four labeled tabs. Add habit lives on Today only.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [TodayScreen(), StatsScreen(), WidgetsScreen(), SettingsScreen()],
      ),
      floatingActionButton: _index == 0 && context.store.habits.isNotEmpty
          ? FloatingActionButton(
              tooltip: l.addHabit,
              onPressed: () => openHabitForm(context),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline_rounded),
            selectedIcon: const Icon(Icons.check_circle_rounded),
            label: l.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights_rounded),
            label: l.tabStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.widgets_outlined),
            selectedIcon: const Icon(Icons.widgets_rounded),
            label: l.tabWidgets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l.tabSettings,
          ),
        ],
      ),
    );
  }
}
