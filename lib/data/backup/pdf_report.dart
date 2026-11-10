import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/theme/habit_palette.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../../domain/stats.dart';
import 'backup_data.dart';

/// Fonts for the report. Noto Sans covers most scripts; the Bengali font is a
/// fallback for Bangla habit names and notes.
class ReportFonts {
  const ReportFonts({required this.regular, required this.bold, required this.bengali});

  final ByteData regular;
  final ByteData bold;
  final ByteData bengali;
}

const _brand = PdfColor.fromInt(0xFF1769B8);
const _muted = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFE5E7EB);
const _missed = PdfColor.fromInt(0xFFF1F1EC);
const _historyDays = 30;
const _maxNotes = 200;

/// Builds a readable habit report as a PDF, with [data] embedded so the same
/// file can be imported again.
Future<Uint8List> buildPdfReport(BackupData data, ReportFonts fonts, {required DateTime today}) async {
  final doc = pw.Document(
    title: 'Ovvas habit report',
    author: data.userName,
    creator: 'Ovvas',
    theme: pw.ThemeData.withFont(
      base: pw.Font.ttf(fonts.regular),
      bold: pw.Font.ttf(fonts.bold),
      fontFallback: [pw.Font.ttf(fonts.bengali)],
    ),
  );

  final day = dateOnly(today);
  final stats = Stats(data.entry, today: day);
  final active = data.habits.where((h) => !h.archived).toList();
  final archived = data.habits.where((h) => h.archived).toList();
  final from = addDays(day, -(_historyDays - 1));
  final summary = stats.summarize(active, from, day);
  final dateFmt = DateFormat.yMMMd();

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    footer: (ctx) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Ovvas · ${dateFmt.format(data.createdAt)}', style: const pw.TextStyle(fontSize: 8, color: _muted)),
        pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: _muted)),
      ],
    ),
    build: (ctx) => [
      // Header
      pw.Text('Habit report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _brand)),
      pw.SizedBox(height: 4),
      pw.Text(
        [if (data.userName.isNotEmpty) data.userName, 'Created ${dateFmt.format(data.createdAt)}'].join(' · '),
        style: const pw.TextStyle(color: _muted),
      ),
      pw.SizedBox(height: 16),

      // Summary
      pw.Row(children: [
        _tile('Active habits', '${active.length}'),
        _tile('Last $_historyDays days', summary.rate == null ? '–' : '${(summary.rate! * 100).round()}%'),
        _tile('Perfect days', '${summary.perfectDays}'),
        _tile('Check-ins logged', '${data.entryCount}'),
      ]),
      pw.SizedBox(height: 20),

      // Habits table
      _heading('Habits'),
      if (active.isEmpty)
        pw.Text('No active habits.', style: const pw.TextStyle(color: _muted))
      else
        _habitTable(active, stats, from, day),
      if (archived.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        _heading('Archived'),
        _habitTable(archived, stats, from, day),
      ],
      pw.SizedBox(height: 20),

      // Last 30 days grid
      if (active.isNotEmpty) ...[
        _heading('Last $_historyDays days'),
        _historyGrid(active, stats, from, day),
        pw.SizedBox(height: 6),
        pw.Row(children: [
          _legend(PdfColor.fromInt(kHabitColors.first.toARGB32()), 'Done'),
          _legend(_tint(PdfColor.fromInt(kHabitColors.first.toARGB32())), 'Partly done'),
          _legend(_missed, 'Missed'),
          _legend(PdfColors.white, 'Skipped / not scheduled', border: true),
        ]),
        pw.SizedBox(height: 20),
      ],

      // Notes
      ..._notes(data, dateFmt),
    ],
  ));

  return data.embedIn(await doc.save());
}

pw.Widget _heading(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _brand)),
    );

pw.Widget _tile(String label, String value) => pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(right: 8),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _line), borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _muted)),
        ]),
      ),
    );

/// A light version of [c], for days that were only partly done.
PdfColor _tint(PdfColor c) => PdfColor(c.red, c.green, c.blue, 0.35).flatten();

PdfColor _habitColor(Habit h) => PdfColor.fromInt(kHabitColors[h.colorIndex % kHabitColors.length].toARGB32());

String _goal(Habit h) => switch (h.goalType) {
      GoalType.yesNo => 'Yes / No',
      GoalType.count => '${h.target}${h.unit.isEmpty ? '' : ' ${h.unit}'}',
      GoalType.time => '${h.target} min',
    };

String _repeat(Habit h) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return switch (h.repeat) {
    RepeatKind.everyDay => 'Every day',
    RepeatKind.weekdays => (h.weekdays.toList()..sort()).map((d) => names[d - 1]).join(', '),
    RepeatKind.timesPerWeek => '${h.timesPerWeek}× a week',
  };
}

pw.Widget _habitTable(List<Habit> habits, Stats stats, DateTime from, DateTime to) {
  const header = pw.TextStyle(fontSize: 9, color: _muted);
  const cell = pw.TextStyle(fontSize: 10);
  pw.Widget pad(pw.Widget w) => pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4), child: w);

  return pw.Table(
    columnWidths: const {
      0: pw.FlexColumnWidth(3),
      1: pw.FlexColumnWidth(1.4),
      2: pw.FlexColumnWidth(1.8),
      3: pw.FlexColumnWidth(1),
      4: pw.FlexColumnWidth(1),
      5: pw.FlexColumnWidth(1),
    },
    border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _line, width: 0.5)),
    children: [
      pw.TableRow(children: [
        for (final t in ['Habit', 'Goal', 'Repeat', 'Streak', 'Best', '30 days']) pad(pw.Text(t, style: header)),
      ]),
      for (final h in habits)
        pw.TableRow(verticalAlignment: pw.TableCellVerticalAlignment.middle, children: [
          pad(pw.Row(children: [
            pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: _habitColor(h), shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 6),
            pw.Expanded(child: pw.Text(h.name, style: cell.copyWith(fontWeight: pw.FontWeight.bold))),
          ])),
          pad(pw.Text(_goal(h), style: cell)),
          pad(pw.Text(_repeat(h), style: cell)),
          pad(pw.Text('${stats.currentStreak(h)}', style: cell)),
          pad(pw.Text('${stats.bestStreak(h)}', style: cell)),
          pad(pw.Text(_percent(stats.habitStat(h, from, to).rate), style: cell)),
        ]),
    ],
  );
}

String _percent(double? rate) => rate == null ? '–' : '${(rate * 100).round()}%';

pw.Widget _historyGrid(List<Habit> habits, Stats stats, DateTime from, DateTime to) {
  final days = daysInRange(from, to).toList();
  const cellSize = 11.0;

  pw.Widget square(Habit h, DateTime d) {
    final color = _habitColor(h);
    final (fill, border) = switch (stats.status(h, d)) {
      DayStatus.done => (color, false),
      DayStatus.partial => (_tint(color), false),
      DayStatus.missed => (_missed, false),
      _ => (PdfColors.white, true),
    };
    return pw.Container(
      width: cellSize,
      height: cellSize,
      margin: const pw.EdgeInsets.all(1),
      decoration: pw.BoxDecoration(
        color: fill,
        borderRadius: pw.BorderRadius.circular(2),
        border: border ? pw.Border.all(color: _line, width: 0.5) : null,
      ),
    );
  }

  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    // Day numbers
    pw.Row(children: [
      pw.SizedBox(width: 110),
      for (final d in days)
        pw.SizedBox(
          width: cellSize + 2,
          child: pw.Text(
            d.day == 1 || d == days.first || d.day % 5 == 0 ? '${d.day}' : '',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 6, color: _muted),
          ),
        ),
    ]),
    for (final h in habits)
      pw.Row(children: [
        pw.SizedBox(
          width: 110,
          child: pw.Text(h.name, maxLines: 1, overflow: pw.TextOverflow.clip, style: const pw.TextStyle(fontSize: 9)),
        ),
        for (final d in days) square(h, d),
      ]),
  ]);
}

pw.Widget _legend(PdfColor color, String label, {bool border = false}) => pw.Padding(
      padding: const pw.EdgeInsets.only(right: 12),
      child: pw.Row(children: [
        pw.Container(
          width: 8,
          height: 8,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(2),
            border: border ? pw.Border.all(color: _line, width: 0.5) : null,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
      ]),
    );

List<pw.Widget> _notes(BackupData data, DateFormat dateFmt) {
  final names = {for (final h in data.habits) h.id: h.name};
  final notes = <(DateTime, String, String)>[
    for (final MapEntry(key: id, value: days) in data.entries.entries)
      for (final MapEntry(key: d, value: e) in days.entries)
        if (e.note.isNotEmpty) (d, names[id] ?? '', e.note),
  ]..sort((a, b) => b.$1.compareTo(a.$1));
  if (notes.isEmpty) return const [];

  return [
    _heading('Notes'),
    for (final (d, habit, note) in notes.take(_maxNotes))
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('${dateFmt.format(d)} · $habit', style: const pw.TextStyle(fontSize: 8, color: _muted)),
          pw.Text(note, style: const pw.TextStyle(fontSize: 10)),
        ]),
      ),
    if (notes.length > _maxNotes)
      pw.Text('…and ${notes.length - _maxNotes} older notes (kept in the file for import).',
          style: const pw.TextStyle(fontSize: 8, color: _muted)),
  ];
}
