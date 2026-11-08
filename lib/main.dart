import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/habit_store.dart';
import 'data/local/database.dart';
import 'data/sample_data.dart';
import 'data/settings_controller.dart';
import 'data/sync/cloud_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.onDevice();
  final cloud = await createCloudSync(db);

  final store = HabitStore(db: db, cloud: cloud);
  await store.reload();
  // Debug builds start with sample habits on a fresh install, so every
  // screen has something to show. Release builds start empty.
  if (kDebugMode && await db.isEmpty) seedSampleData(store);

  final settings = SettingsController(db: db);
  await settings.load();

  runApp(OvvasApp(store: store, settings: settings));
}
