import 'dart:convert';

import 'package:flutter/material.dart';

import '../domain/habit.dart';
import 'local/database.dart';

/// User preferences, saved on the phone when a database is given.
class SettingsController extends ChangeNotifier {
  SettingsController({this._db});

  static const textScales = [1.0, 1.15, 1.3];
  static const _key = 'settings';

  final AppDatabase? _db;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  int _firstWeekday = DateTime.monday;
  double _textScale = 1.0;
  bool _haptics = true;
  bool _animations = true;
  bool _celebrations = true;
  bool _dailySummary = false;
  bool _weeklyReport = true;
  String _userName = 'User';
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
    _db?.writeValue(_key, jsonEncode(_toJson())).catchError((Object e) => debugPrint('Saving settings failed: $e'));
  }

  /// Reads saved settings. Missing or unreadable values keep their defaults.
  Future<void> load() async {
    final raw = await _db?.readValue(_key);
    if (raw == null) return;
    try {
      _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Reading settings failed: $e');
    }
    notifyListeners();
  }

  Map<String, Object?> _toJson() => {
        'themeMode': _themeMode.name,
        'locale': _locale.languageCode,
        'firstWeekday': _firstWeekday,
        'textScale': _textScale,
        'haptics': _haptics,
        'animations': _animations,
        'celebrations': _celebrations,
        'dailySummary': _dailySummary,
        'weeklyReport': _weeklyReport,
        'userName': _userName,
        'defaultReminder': _defaultReminder.minutesOfDay,
        'quietStart': _quietStart.minutesOfDay,
        'quietEnd': _quietEnd.minutesOfDay,
      };

  void _fromJson(Map<String, dynamic> m) {
    T? read<T>(String k) => m[k] is T ? m[k] as T : null;
    ReminderTime? time(String k) {
      final v = read<int>(k);
      return v == null ? null : ReminderTime(v ~/ 60, v % 60);
    }

    _themeMode = ThemeMode.values.asNameMap()[read<String>('themeMode')] ?? _themeMode;
    final lang = read<String>('locale');
    if (lang != null) _locale = Locale(lang);
    _firstWeekday = read<int>('firstWeekday') ?? _firstWeekday;
    _textScale = read<num>('textScale')?.toDouble() ?? _textScale;
    _haptics = read<bool>('haptics') ?? _haptics;
    _animations = read<bool>('animations') ?? _animations;
    _celebrations = read<bool>('celebrations') ?? _celebrations;
    _dailySummary = read<bool>('dailySummary') ?? _dailySummary;
    _weeklyReport = read<bool>('weeklyReport') ?? _weeklyReport;
    _userName = read<String>('userName') ?? _userName;
    _defaultReminder = time('defaultReminder') ?? _defaultReminder;
    _quietStart = time('quietStart') ?? _quietStart;
    _quietEnd = time('quietEnd') ?? _quietEnd;
  }
}
