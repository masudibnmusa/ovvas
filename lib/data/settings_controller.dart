import 'package:flutter/material.dart';

import '../domain/habit.dart';

/// User preferences. Kept in memory for now; will be persisted and backed up.
class SettingsController extends ChangeNotifier {
  static const textScales = [1.0, 1.15, 1.3];

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  int _firstWeekday = DateTime.monday;
  double _textScale = 1.0;
  bool _haptics = true;
  bool _animations = true;
  bool _celebrations = true;
  bool _dailySummary = false;
  bool _weeklyReport = true;
  String _userName = 'Nabila';
  ReminderTime _defaultReminder = const ReminderTime(9, 0);
  ReminderTime _quietStart = const ReminderTime(22, 0);
  ReminderTime _quietEnd = const ReminderTime(7, 0);

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  int get firstWeekday => _firstWeekday;
  double get textScale => _textScale;
  bool get haptics => _haptics;
  bool get animations => _animations;
  bool get celebrations => _celebrations;
  bool get dailySummary => _dailySummary;
  bool get weeklyReport => _weeklyReport;
  String get userName => _userName;
  ReminderTime get defaultReminder => _defaultReminder;
  ReminderTime get quietStart => _quietStart;
  ReminderTime get quietEnd => _quietEnd;

  set themeMode(ThemeMode v) => _set(() => _themeMode = v);
  set locale(Locale v) => _set(() => _locale = v);
  set firstWeekday(int v) => _set(() => _firstWeekday = v);
  set textScale(double v) => _set(() => _textScale = v);
  set haptics(bool v) => _set(() => _haptics = v);
  set animations(bool v) => _set(() => _animations = v);
  set celebrations(bool v) => _set(() => _celebrations = v);
  set dailySummary(bool v) => _set(() => _dailySummary = v);
  set weeklyReport(bool v) => _set(() => _weeklyReport = v);
  set userName(String v) => _set(() => _userName = v.trim());
  set defaultReminder(ReminderTime v) => _set(() => _defaultReminder = v);
  set quietStart(ReminderTime v) => _set(() => _quietStart = v);
  set quietEnd(ReminderTime v) => _set(() => _quietEnd = v);

  void _set(VoidCallback change) {
    change();
    notifyListeners();
  }
}
