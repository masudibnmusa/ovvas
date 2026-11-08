import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../data/backup/backup_data.dart';
import '../../data/backup/pdf_report.dart';
import '../../data/local/records.dart' show dayKey;
import '../common/dialogs.dart';

/// Saves a PDF report of all habits. The file also carries the data, so
/// [importPdf] can restore it later.
Future<void> exportPdf(BuildContext context) async {
  final store = context.store;
  final l = context.l10n;
  final userName = context.settings.userName;
  try {
    await store.flush();
    final fonts = ReportFonts(
      regular: await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      bold: await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      bengali: await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    );
    final bytes = await buildPdfReport(store.exportBackup(userName: userName), fonts, today: store.today);
    final saved = await FilePicker.saveFile(
      fileName: 'ovvas-report-${dayKey(store.today)}.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
      dialogTitle: l.exportData,
    );
    if (saved != null && context.mounted) context.showSnack(l.exportSaved);
  } catch (e, s) {
    debugPrint('Export failed: $e\n$s');
    if (context.mounted) context.showSnack(l.exportFailed);
  }
}

/// Lets the user pick a PDF exported by Ovvas and merges its data in.
Future<void> importPdf(BuildContext context) async {
  final store = context.store;
  final l = context.l10n;
  final BackupData? data;
  try {
    final file = await FilePicker.pickFile(
      dialogTitle: l.importData,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (file == null) return;
    data = BackupData.extractFrom(await file.readAsBytes());
  } catch (e, s) {
    debugPrint('Import failed: $e\n$s');
    if (context.mounted) context.showSnack(l.importFailed);
    return;
  }
  if (!context.mounted) return;
  if (data == null) {
    context.showSnack(l.importNotOvvas);
    return;
  }

  final ok = await confirmAction(
    context,
    title: l.importConfirmTitle,
    message: l.importConfirmMessage(data.habits.length),
    confirmLabel: l.importAction,
  );
  if (!ok || !context.mounted) return;
  final count = store.importBackup(data);
  context.showSnack(l.importDone(count));
}
