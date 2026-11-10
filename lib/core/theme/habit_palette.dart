import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The curated palette of 12 habit colors.
const kHabitColors = <Color>[
  Color(0xFF2A9D8F), // teal
  Color(0xFF3FA66B), // green
  Color(0xFF3F7FD6), // blue
  Color(0xFF6A61D8), // indigo
  Color(0xFF9B59C7), // purple
  Color(0xFFD1588A), // pink
  Color(0xFFE0735A), // coral
  Color(0xFFE38B3C), // orange
  Color(0xFFCFA22A), // amber
  Color(0xFF8C9B36), // olive
  Color(0xFFA0714F), // brown
  Color(0xFF5B7C8C), // slate
];

/// One rounded icon set for habits.
const kHabitIcons = <IconData>[
  Icons.water_drop_rounded,
  Icons.menu_book_rounded,
  Icons.directions_walk_rounded,
  Icons.self_improvement_rounded,
  Icons.fitness_center_rounded,
  Icons.bedtime_rounded,
  Icons.restaurant_rounded,
  Icons.no_food_rounded,
  Icons.school_rounded,
  Icons.edit_note_rounded,
  Icons.music_note_rounded,
  Icons.spa_rounded,
  Icons.directions_run_rounded,
  Icons.local_florist_rounded,
  Icons.savings_rounded,
  Icons.smartphone_rounded,
  Icons.brush_rounded,
  Icons.favorite_rounded,
];

/// Soft circle fill plus a readable icon color for one habit color.
class HabitTint {
  const HabitTint(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

HabitTint habitTintFor(Brightness brightness, int colorIndex) {
  final base = kHabitColors[colorIndex % kHabitColors.length];
  if (brightness == Brightness.dark) {
    return HabitTint(
      Color.alphaBlend(base.withValues(alpha: 0.26), AppColors.dark.surface),
      Color.lerp(base, Colors.white, 0.45)!,
    );
  }
  return HabitTint(Color.lerp(base, Colors.white, 0.84)!, Color.lerp(base, Colors.black, 0.35)!);
}

HabitTint habitTint(BuildContext context, int colorIndex) =>
    habitTintFor(Theme.of(context).brightness, colorIndex);

/// Guesses an icon and color from a habit name ("Drink water" -> water drop).
({int icon, int color})? suggestStyle(String name) {
  final n = name.toLowerCase();
  const rules = <(List<String>, int, int)>[
    (['water', 'drink', 'পানি', 'জল'], 0, 2),
    (['read', 'book', 'page', 'পড়', 'বই'], 1, 3),
    (['walk', 'step', 'হাঁট'], 2, 1),
    (['meditat', 'stretch', 'yoga', 'breath', 'ধ্যান', 'যোগ'], 3, 0),
    (['gym', 'workout', 'exercise', 'push', 'ব্যায়াম'], 4, 6),
    (['sleep', 'bed', 'ঘুম'], 5, 3),
    (['eat', 'cook', 'meal', 'breakfast', 'খাও', 'রান্না'], 6, 7),
    (['sugar', 'snack', 'junk', 'চিনি'], 7, 5),
    (['study', 'learn', 'class', 'পড়াশোনা'], 8, 2),
    (['journal', 'write', 'diary', 'লিখ'], 9, 10),
    (['music', 'guitar', 'piano', 'sing', 'গান'], 10, 4),
    (['run', 'jog', 'দৌড়'], 12, 7),
    (['plant', 'garden', 'গাছ'], 13, 1),
    (['save', 'money', 'budget', 'সঞ্চয়'], 14, 8),
    (['phone', 'screen', 'social', 'ফোন'], 15, 11),
    (['draw', 'paint', 'art', 'আঁক'], 16, 5),
    (['pray', 'namaz', 'salah', 'নামাজ', 'gratitude'], 17, 0),
  ];
  for (final (words, icon, color) in rules) {
    if (words.any(n.contains)) return (icon: icon, color: color);
  }
  return null;
}

/// Supporting UI accents, drawn from the habit palette so the whole app
/// shares one family of colors. Sky blue is the brand color; the others mark
/// meaning (a tab, a kind of stat, a group of settings).
enum Accent {
  teal(0),
  green(1),
  sky(2),
  violet(3),
  rose(5),
  coral(6),
  amber(8);

  const Accent(this.colorIndex);

  final int colorIndex;
}

/// Soft fill plus readable foreground for an [Accent].
HabitTint accentTint(BuildContext context, Accent a) => habitTint(context, a.colorIndex);

/// Solid fill for a "done" state in a habit's own color, with the icon color
/// to put on top of it.
({Color fill, Color onFill}) habitSolid(BuildContext context, int colorIndex) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final tint = habitTint(context, colorIndex);
  return dark
      ? (fill: tint.foreground, onFill: AppColors.dark.background)
      : (fill: tint.foreground, onFill: Colors.white);
}
