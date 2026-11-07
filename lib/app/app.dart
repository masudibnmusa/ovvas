import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/habit_store.dart';
import '../data/settings_controller.dart';
import '../l10n/app_localizations.dart';
import '../ui/home_shell.dart';
import 'app_scope.dart';

class HabitoApp extends StatefulWidget {
  const HabitoApp({super.key, required this.store, required this.settings});

  final HabitStore store;
  final SettingsController settings;

  @override
  State<HabitoApp> createState() => _HabitoAppState();
}

class _HabitoAppState extends State<HabitoApp> {
  late final Listenable _changes = Listenable.merge([widget.store, widget.settings]);
  final _lightTheme = buildTheme(AppColors.light);
  final _darkTheme = buildTheme(AppColors.dark);

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: widget.store,
      settings: widget.settings,
      notifier: _changes,
      child: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) {
          final s = widget.settings;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (c) => AppLocalizations.of(c).appName,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: s.themeMode,
            locale: s.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) {
              // Apply the in-app text size on top of the system font size.
              final mq = MediaQuery.of(context);
              final system = mq.textScaler.scale(14) / 14;
              return MediaQuery(
                data: mq.copyWith(textScaler: TextScaler.linear(system * s.textScale)),
                child: child!,
              );
            },
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
