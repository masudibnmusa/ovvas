import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/habit_store.dart';
import '../data/settings_controller.dart';
import '../l10n/app_localizations.dart';
import '../ui/home_shell.dart';
import 'app_scope.dart';

class OvvasApp extends StatefulWidget {
  const OvvasApp({super.key, required this.store, required this.settings});

  final HabitStore store;
  final SettingsController settings;

  @override
  State<OvvasApp> createState() => _OvvasAppState();
}

class _OvvasAppState extends State<OvvasApp> {
  late final Listenable _changes = Listenable.merge([widget.store, widget.settings]);
  final _lightTheme = buildTheme(AppColors.light);
  final _darkTheme = buildTheme(AppColors.dark);

  void _syncWeekStart() => widget.store.firstWeekday = widget.settings.firstWeekday;

  @override
  void initState() {
    super.initState();
    _syncWeekStart();
    widget.settings.addListener(_syncWeekStart);
  }

  @override
  void dispose() {
    widget.settings.removeListener(_syncWeekStart);
    super.dispose();
  }

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
              return MediaQuery(
                data: mq.copyWith(textScaler: _ExtraScale(mq.textScaler, s.textScale)),
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

/// The in-app text size on top of the system's scaling, keeping the
/// system's non-linear curve (large text grows less than small text).
class _ExtraScale extends TextScaler {
  const _ExtraScale(this.system, this.factor);

  final TextScaler system;
  final double factor;

  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => system.textScaleFactor * factor;

  @override
  bool operator ==(Object other) => other is _ExtraScale && other.system == system && other.factor == factor;

  @override
  int get hashCode => Object.hash(system, factor);
}
