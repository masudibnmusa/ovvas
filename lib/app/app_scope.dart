import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../data/habit_store.dart';
import '../data/settings_controller.dart';
import '../l10n/app_localizations.dart';

/// Makes the store and settings available to every screen. Widgets that read
/// them rebuild when either changes.
class AppScope extends InheritedNotifier<Listenable> {
  const AppScope({
    super.key,
    required this.store,
    required this.settings,
    required super.notifier,
    required super.child,
  });

  final HabitStore store;
  final SettingsController settings;

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  static AppScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>();
}

extension AppContext on BuildContext {
  HabitStore get store => AppScope.of(this).store;
  SettingsController get settings => AppScope.of(this).settings;
  AppLocalizations get l10n => AppLocalizations.of(this);
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// Animation length, or zero when the user turned motion off.
  Duration motion(int milliseconds) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(this) ?? false;
    final enabled = AppScope.maybeOf(this)?.settings.animations ?? true;
    return (reduce || !enabled) ? Duration.zero : Duration(milliseconds: milliseconds);
  }

  /// A light tick on check, a softer one on undo.
  void haptic({bool soft = false}) {
    if (!(AppScope.maybeOf(this)?.settings.haptics ?? false)) return;
    soft ? HapticFeedback.selectionClick() : HapticFeedback.lightImpact();
  }

  void showSnack(String message, {String? actionLabel, VoidCallback? onAction}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ));
  }
}
