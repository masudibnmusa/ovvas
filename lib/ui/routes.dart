import 'package:flutter/material.dart';

import '../domain/habit.dart';
import '../domain/widget_config.dart';
import 'habit/habit_detail_screen.dart';
import 'habit/habit_form_screen.dart';
import 'widgets/widget_builder_screen.dart';

Future<void> openHabitForm(BuildContext context, {Habit? habit}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)));

Future<void> openHabitDetail(BuildContext context, String habitId) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: habitId)));

Future<void> openWidgetBuilder(BuildContext context, WidgetConfig config, {required bool isNew}) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WidgetBuilderScreen(initial: config, isNew: isNew)),
    );
