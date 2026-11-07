import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/habit_store.dart';
import 'data/sample_data.dart';
import 'data/settings_controller.dart';

void main() {
  // Frontend-only build: sample data stands in for the database and cloud backup.
  final store = HabitStore();
  seedSampleData(store);
  runApp(HabitoApp(store: store, settings: SettingsController()));
}
