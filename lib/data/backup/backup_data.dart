import 'dart:convert';
import 'dart:typed_data';

import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../local/records.dart' show dayKey, parseDay;

/// Everything an exported file carries: habits (archived ones too) and their
/// check-ins. Widgets and settings are not included.
class BackupData {
  BackupData({required this.habits, required this.entries, required this.createdAt, this.userName = ''});

  final List<Habit> habits;

  /// Check-ins by habit id, then by day.
  final Map<String, Map<DateTime, DayEntry>> entries;
  final DateTime createdAt;
  final String userName;

  static const _format = 'ovvas-backup';
  static const _version = 1;

  DayEntry? entry(String habitId, DateTime day) => entries[habitId]?[dateOnly(day)];

  int get entryCount => entries.values.fold(0, (sum, m) => sum + m.length);

  Map<String, Object?> toJson() => {
        'format': _format,
        'version': _version,
        'createdAt': createdAt.toIso8601String(),
        'userName': userName,
        'habits': [for (final h in habits) _habitToJson(h)],
        'entries': [
          for (final MapEntry(key: id, value: days) in entries.entries)
            for (final MapEntry(key: day, value: e) in days.entries)
              if (!e.isEmpty) {'habitId': id, 'day': dayKey(day), 'value': e.value, 'skipped': e.skipped, 'note': e.note},
        ],
      };

  /// Returns null when [json] is not an Ovvas backup this version can read.
  static BackupData? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    if (json['format'] != _format) return null;
    final version = json['version'];
    if (version is! int || version > _version) return null;
    try {
      final habits = [for (final h in json['habits'] as List) _habitFromJson(h as Map<String, dynamic>)];
      final ids = {for (final h in habits) h.id};
      final entries = <String, Map<DateTime, DayEntry>>{};
      for (final raw in json['entries'] as List) {
        final m = raw as Map<String, dynamic>;
        final id = m['habitId'] as String;
        if (!ids.contains(id)) continue;
        entries.putIfAbsent(id, () => {})[parseDay(m['day'] as String)] = DayEntry(
          value: m['value'] as int,
          skipped: m['skipped'] as bool,
          note: m['note'] as String? ?? '',
        );
      }
      return BackupData(
        habits: habits,
        entries: entries,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        userName: json['userName'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  // ---- Inside a PDF ----
  //
  // The data rides along in the PDF as one comment line just before the final
  // "%%EOF". PDF readers skip comments, and the cross-reference offsets point
  // to earlier bytes, so the report still opens normally everywhere.

  static const _marker = '%OVVAS-BACKUP-1 ';

  Uint8List embedIn(Uint8List pdf) {
    final line = ascii.encode('$_marker${base64.encode(utf8.encode(jsonEncode(toJson())))}\n');
    final eof = _lastIndexOf(pdf, ascii.encode('%%EOF'));
    final at = eof < 0 ? pdf.length : eof;
    return Uint8List.fromList([...pdf.sublist(0, at), ...line, ...pdf.sublist(at)]);
  }

  /// Reads the data back from a PDF made by [embedIn]. Returns null for any
  /// other file.
  static BackupData? extractFrom(Uint8List pdf) {
    final start = _lastIndexOf(pdf, ascii.encode(_marker));
    if (start < 0) return null;
    final from = start + _marker.length;
    var end = from;
    while (end < pdf.length && pdf[end] != 0x0A && pdf[end] != 0x0D) {
      end++;
    }
    try {
      final text = utf8.decode(base64.decode(ascii.decode(pdf.sublist(from, end))));
      return fromJson(jsonDecode(text));
    } catch (_) {
      return null;
    }
  }

  static int _lastIndexOf(List<int> data, List<int> pattern) {
    outer:
    for (var i = data.length - pattern.length; i >= 0; i--) {
      for (var j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) continue outer;
      }
      return i;
    }
    return -1;
  }
}

Map<String, Object?> _habitToJson(Habit h) => {
      'id': h.id,
      'name': h.name,
      'iconIndex': h.iconIndex,
      'colorIndex': h.colorIndex,
      'goalType': h.goalType.name,
      'target': h.target,
      'unit': h.unit,
      'repeat': h.repeat.name,
      'weekdays': h.weekdays.toList()..sort(),
      'timesPerWeek': h.timesPerWeek,
      'reminders': [for (final r in h.reminders) r.minutesOfDay],
      'startDate': dayKey(h.startDate),
      'endDate': h.endDate == null ? null : dayKey(h.endDate!),
      'note': h.note,
      'archived': h.archived,
    };

Habit _habitFromJson(Map<String, dynamic> m) => Habit(
      id: m['id'] as String,
      name: m['name'] as String,
      iconIndex: m['iconIndex'] as int,
      colorIndex: m['colorIndex'] as int,
      goalType: GoalType.values.asNameMap()[m['goalType']] ?? GoalType.yesNo,
      target: m['target'] as int,
      unit: m['unit'] as String? ?? '',
      repeat: RepeatKind.values.asNameMap()[m['repeat']] ?? RepeatKind.everyDay,
      weekdays: {for (final d in m['weekdays'] as List) d as int},
      timesPerWeek: m['timesPerWeek'] as int,
      reminders: [for (final x in m['reminders'] as List) ReminderTime((x as int) ~/ 60, x % 60)],
      startDate: parseDay(m['startDate'] as String),
      endDate: m['endDate'] == null ? null : parseDay(m['endDate'] as String),
      note: m['note'] as String? ?? '',
      archived: m['archived'] as bool? ?? false,
    );
