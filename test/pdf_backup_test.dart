import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovvas/data/backup/backup_data.dart';
import 'package:ovvas/data/backup/pdf_report.dart';
import 'package:ovvas/data/habit_store.dart';
import 'package:ovvas/data/local/database.dart';
import 'package:ovvas/data/sample_data.dart';
import 'package:ovvas/domain/dates.dart';
import 'package:ovvas/domain/habit.dart';

final _now = DateTime(2026, 10, 21, 9, 30);

ByteData _font(String name) => ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync());

final _fonts = ReportFonts(
  regular: _font('NotoSans-Regular.ttf'),
  bold: _font('NotoSans-Bold.ttf'),
  bengali: _font('NotoSansBengali-Regular.ttf'),
);

void main() {
  test('an exported PDF imports back into an empty app', () async {
    final source = HabitStore(clock: () => _now);
    seedSampleData(source);
    final h = source.habits.first;
    source.setNote(h, source.today, 'বই পড়া — felt good');
    source.setArchived(source.habits.last.id, true);

    final pdf = await buildPdfReport(source.exportBackup(userName: 'User'), _fonts, today: source.today);
    expect(String.fromCharCodes(pdf.sublist(0, 5)), '%PDF-');
    expect(String.fromCharCodes(pdf.sublist(pdf.length - 6)).trim(), '%%EOF');

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final target = HabitStore(clock: () => _now, db: db);
    final data = BackupData.extractFrom(pdf)!;
    expect(target.importBackup(data), source.habits.length + source.archivedHabits.length);

    // Survives a restart, so it reached the database too.
    await target.flush();
    final reopened = HabitStore(clock: () => _now, db: db);
    await reopened.reload();

    expect(reopened.habits.map((x) => x.name), source.habits.map((x) => x.name));
    expect(reopened.archivedHabits.map((x) => x.id), source.archivedHabits.map((x) => x.id));
    expect(reopened.entry(h.id, source.today)?.note, 'বই পড়া — felt good');
    for (final habit in source.habits) {
      for (var i = 0; i < 30; i++) {
        final d = addDays(source.today, -i);
        expect(reopened.entry(habit.id, d)?.value, source.entry(habit.id, d)?.value, reason: '${habit.name} $d');
      }
    }
  });

  test('import merges: same habit is updated, others are kept', () {
    final store = HabitStore(clock: () => _now);
    final keep = Habit(id: 'a', name: 'Walk', iconIndex: 0, colorIndex: 0, startDate: store.today);
    final old = Habit(id: 'b', name: 'Read', iconIndex: 0, colorIndex: 0, startDate: store.today);
    store
      ..addHabit(keep)
      ..addHabit(old);

    final data = BackupData(
      habits: [old.copyWith(name: 'Read more')],
      entries: {
        'b': {store.today: const DayEntry(value: 1)},
      },
      createdAt: _now,
    );
    store.importBackup(BackupData.fromJson(data.toJson())!);

    expect(store.habits.map((x) => x.name), ['Walk', 'Read more']);
    expect(store.entry('b', store.today)?.value, 1);
  });

  test('a PDF not made by Ovvas is rejected', () {
    final other = Uint8List.fromList('%PDF-1.4\n1 0 obj\n<<>>\nendobj\n%%EOF\n'.codeUnits);
    expect(BackupData.extractFrom(other), isNull);
  });
}
