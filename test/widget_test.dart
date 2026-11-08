import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovvas/app/app.dart';
import 'package:ovvas/data/habit_store.dart';
import 'package:ovvas/data/sample_data.dart';
import 'package:ovvas/data/settings_controller.dart';
import 'package:ovvas/domain/dates.dart';
import 'package:ovvas/domain/habit.dart';

// Wednesday, like the mockups.
final _now = DateTime(2026, 10, 21, 9, 30);

HabitStore _sampleStore() {
  final store = HabitStore(clock: () => _now);
  seedSampleData(store);
  return store;
}

Future<void> _pumpApp(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
  String lang = 'en',
  double width = 360,
  double textScale = 1.0,
  HabitStore? store,
}) async {
  // A tall surface so long lists are fully built and checked for overflow.
  tester.view.physicalSize = Size(width * 3, 2600 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final settings = SettingsController()
    ..themeMode = mode
    ..locale = Locale(lang)
    ..textScale = textScale;
  await tester.pumpWidget(OvvasApp(store: store ?? _sampleStore(), settings: settings));
  await tester.pumpAndSettle();
}

Finder _tab(IconData icon) => find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(icon));

// tester.pageBack() looks for an English "Back" tooltip, so it fails in Bangla.
Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> _visitEverything(WidgetTester tester) async {
  // Today -> habit detail -> back
  await tester.tap(find.text('Drink water').first);
  await tester.pumpAndSettle();
  await _back(tester);

  // Add habit form
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await _back(tester);

  // Stats: week, then month
  await tester.tap(_tab(Icons.insights_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
  await tester.pumpAndSettle();

  // Widgets: gallery, then the builder for every widget type
  await tester.tap(_tab(Icons.widgets_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.checklist_rounded).first);
  await tester.pumpAndSettle();
  final chips = find.byType(ChoiceChip);
  for (var i = 0; i < 6; i++) {
    await tester.tap(chips.at(i));
    await tester.pumpAndSettle();
  }
  await _back(tester);

  // Settings
  await tester.tap(_tab(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

void main() {
  group('Stats', () {
    test('streak skips skipped days and stops at a miss', () {
      final store = HabitStore(clock: () => _now);
      final today = store.today;
      final h = Habit(id: 'a', name: 'Walk', iconIndex: 0, colorIndex: 0, startDate: addDays(today, -10));
      store.addHabit(h);
      for (final d in [-1, -2, -3, -5]) {
        store.setValue(h, addDays(today, d), 1);
      }
      store.setSkipped(h, addDays(today, -4), true);

      final stats = store.stats;
      expect(stats.currentStreak(h), 4);
      expect(stats.bestStreak(h), 4);

      // Days -6..-1: one miss, four done, one skipped (excluded). Today is still open.
      final s = stats.habitStat(h, addDays(today, -6), today);
      expect(s.scheduled, 5);
      expect(s.done, 4);
    });

    test('count habits add a step per tap and undo below the target', () {
      final store = HabitStore(clock: () => _now);
      final h = Habit(
        id: 'w',
        name: 'Water',
        iconIndex: 0,
        colorIndex: 0,
        goalType: GoalType.count,
        target: 2,
        startDate: store.today,
      );
      store.addHabit(h);
      expect(store.toggle(h, store.today), isFalse);
      expect(store.toggle(h, store.today), isTrue);
      expect(store.entry('w', store.today)!.value, 2);
      store.toggle(h, store.today);
      expect(store.entry('w', store.today)!.value, 1);
    });
  });

  testWidgets('one tap checks a habit and a second tap undoes it', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Good morning, Nabila'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Mark Stretch as done'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Stretch is done. Tap to undo.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Stretch is done. Tap to undo.'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Mark Stretch as done'), findsOneWidget);
  });

  testWidgets('sign out switches to local-only, sign in turns backup back on', (tester) async {
    await _pumpApp(tester);
    await tester.tap(_tab(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Saved on this phone only'), findsWidgets);
    expect(find.text('Sign out'), findsNothing);

    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();
    expect(find.text('Backed up just now'), findsWidgets);
  });

  testWidgets('empty state offers to add the first habit', (tester) async {
    await _pumpApp(tester, store: HabitStore(clock: () => _now));
    expect(find.text('Add your first habit'), findsOneWidget);
  });

  testWidgets('every screen renders: light, English', (tester) async {
    await _pumpApp(tester);
    await _visitEverything(tester);
  });

  testWidgets('every screen renders: dark, Bangla', (tester) async {
    await _pumpApp(tester, mode: ThemeMode.dark, lang: 'bn');
    expect(find.text('শুভ সকাল, Nabila'), findsOneWidget);
    await _visitEverything(tester);
  });

  testWidgets('every screen renders: narrow phone with extra large text', (tester) async {
    await _pumpApp(tester, width: 320, textScale: 1.3);
    await _visitEverything(tester);
  });
}
