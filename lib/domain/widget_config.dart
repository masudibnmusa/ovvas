enum WidgetKind { singleHabit, todayList, progressRing, weekStrip, monthHeatmap, streakCounter }

enum WidgetSize {
  small2x1(2, 1),
  small2x2(2, 2),
  medium4x2(4, 2),
  large4x4(4, 4);

  const WidgetSize(this.columns, this.rows);

  final int columns;
  final int rows;

  String get label => '$columns×$rows';
}

/// How the user chooses habits for a widget type.
enum HabitPick { one, oneOrAll, many, all }

extension WidgetKindInfo on WidgetKind {
  List<WidgetSize> get sizes => switch (this) {
        WidgetKind.singleHabit => const [WidgetSize.small2x2],
        WidgetKind.todayList => const [WidgetSize.medium4x2, WidgetSize.large4x4],
        WidgetKind.progressRing => const [WidgetSize.small2x2],
        WidgetKind.weekStrip => const [WidgetSize.medium4x2],
        WidgetKind.monthHeatmap => const [WidgetSize.large4x4],
        WidgetKind.streakCounter => const [WidgetSize.small2x1],
      };

  HabitPick get habitPick => switch (this) {
        WidgetKind.singleHabit || WidgetKind.streakCounter => HabitPick.one,
        WidgetKind.todayList => HabitPick.many,
        WidgetKind.monthHeatmap => HabitPick.oneOrAll,
        WidgetKind.progressRing || WidgetKind.weekStrip => HabitPick.all,
      };

  /// Whether tapping the widget can check a habit directly.
  bool get canCheck => this == WidgetKind.singleHabit || this == WidgetKind.todayList;

  bool get usesWeekStart => this == WidgetKind.weekStrip || this == WidgetKind.monthHeatmap;
}

int maxHabitsFor(WidgetSize size) => size == WidgetSize.large4x4 ? 6 : 3;

enum WidgetTheme { light, dark, device, accent }

enum WidgetBackground { solid, gradient, transparent }

enum WidgetCorner { square, rounded, round }

enum WidgetTextSize { small, medium, large }

enum WidgetTapAction { checkHabit, openToday, openStats }

class WidgetConfig {
  const WidgetConfig({
    required this.id,
    required this.kind,
    required this.size,
    this.habitIds = const [],
    this.theme = WidgetTheme.device,
    this.background = WidgetBackground.solid,
    this.opacity = 1,
    this.corner = WidgetCorner.rounded,
    this.textSize = WidgetTextSize.medium,
    this.showTitle = true,
    this.showStreak = true,
    this.showDate = true,
    this.showPercentage = true,
    this.tapAction = WidgetTapAction.checkHabit,
    this.firstWeekday = DateTime.monday,
  });

  final String id;
  final WidgetKind kind;
  final WidgetSize size;

  /// Habits in display order. Empty means "all habits" where allowed.
  final List<String> habitIds;
  final WidgetTheme theme;
  final WidgetBackground background;

  /// Background opacity when [background] is transparent, 0 to 1.
  final double opacity;
  final WidgetCorner corner;
  final WidgetTextSize textSize;
  final bool showTitle;
  final bool showStreak;
  final bool showDate;
  final bool showPercentage;
  final WidgetTapAction tapAction;
  final int firstWeekday;

  WidgetConfig copyWith({
    WidgetKind? kind,
    WidgetSize? size,
    List<String>? habitIds,
    WidgetTheme? theme,
    WidgetBackground? background,
    double? opacity,
    WidgetCorner? corner,
    WidgetTextSize? textSize,
    bool? showTitle,
    bool? showStreak,
    bool? showDate,
    bool? showPercentage,
    WidgetTapAction? tapAction,
    int? firstWeekday,
  }) {
    return WidgetConfig(
      id: id,
      kind: kind ?? this.kind,
      size: size ?? this.size,
      habitIds: habitIds ?? this.habitIds,
      theme: theme ?? this.theme,
      background: background ?? this.background,
      opacity: opacity ?? this.opacity,
      corner: corner ?? this.corner,
      textSize: textSize ?? this.textSize,
      showTitle: showTitle ?? this.showTitle,
      showStreak: showStreak ?? this.showStreak,
      showDate: showDate ?? this.showDate,
      showPercentage: showPercentage ?? this.showPercentage,
      tapAction: tapAction ?? this.tapAction,
      firstWeekday: firstWeekday ?? this.firstWeekday,
    );
  }
}
