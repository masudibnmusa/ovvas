import 'package:flutter/material.dart';

/// Ovvas color tokens. Screens read colors only from here (via
/// `context.colors`), never hardcoded, so light and dark stay in sync.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.primary,
    required this.onPrimary,
    required this.mint,
    required this.onMint,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.streak,
    required this.trendUp,
    required this.trendDown,
    required this.danger,
    required this.ringTrack,
    required this.shadow,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
    required this.glow,
    required this.cardEdge,
  });

  final Brightness brightness;

  /// Cool off-white page background.
  final Color background;

  /// Cards, sheets, inputs.
  final Color surface;

  /// Segmented controls, steppers, quiet fills.
  final Color surfaceMuted;

  /// Sky blue brand color.
  final Color primary;
  final Color onPrimary;

  /// Soft sky tint (name kept for history).
  final Color mint;
  final Color onMint;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  /// Warm amber for streak flames. Never red.
  final Color streak;
  final Color trendUp;

  /// Neutral gray for a lower period. Never red.
  final Color trendDown;

  /// Only for destructive actions.
  final Color danger;
  final Color ringTrack;
  final Color shadow;

  /// Two ends of the gradient used on hero cards.
  final Color heroStart;
  final Color heroEnd;

  /// Text and ring color on top of the hero gradient.
  final Color onHero;

  /// Soft colored halo around active elements.
  final Color glow;

  /// Hairline around cards. Gives depth in dark mode where shadows vanish.
  final Color cardEdge;

  /// Layered soft shadow for raised surfaces.
  List<BoxShadow> get raised => brightness == Brightness.dark
      ? const []
      : [
          BoxShadow(color: shadow, blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -4),
        ];

  static const light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF4F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFE9F1FA),
    primary: Color(0xFF1769B8),
    onPrimary: Color(0xFFFFFFFF),
    mint: Color(0xFFDCEEFC),
    onMint: Color(0xFF0F4A80),
    textPrimary: Color(0xFF14202E),
    textSecondary: Color(0xFF566577),
    border: Color(0xFFDCE5EF),
    streak: Color(0xFFB87100),
    trendUp: Color(0xFF1769B8),
    trendDown: Color(0xFF66707C),
    danger: Color(0xFFB3261E),
    ringTrack: Color(0xFFDFEBF7),
    shadow: Color(0x1410223A),
    heroStart: Color(0xFF1563AE),
    heroEnd: Color(0xFF1F8AD0),
    onHero: Color(0xFFFFFFFF),
    glow: Color(0x401769B8),
    cardEdge: Color(0x00000000),
  );

  static const dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF0B1622),
    surface: Color(0xFF13212F),
    surfaceMuted: Color(0xFF1A2C3E),
    primary: Color(0xFF6CC4F5),
    onPrimary: Color(0xFF04213A),
    mint: Color(0xFF1C3A55),
    onMint: Color(0xFFCDE8FB),
    textPrimary: Color(0xFFE6EEF6),
    textSecondary: Color(0xFFA3B3C4),
    border: Color(0xFF26394D),
    streak: Color(0xFFF0B85A),
    trendUp: Color(0xFF6CC4F5),
    trendDown: Color(0xFF95A3B2),
    danger: Color(0xFFF2857A),
    ringTrack: Color(0xFF1F3347),
    shadow: Color(0x00000000),
    heroStart: Color(0xFF123D63),
    heroEnd: Color(0xFF1B5A8A),
    onHero: Color(0xFFE8F4FD),
    glow: Color(0x406CC4F5),
    cardEdge: Color(0xFF22364A),
  );

  static AppColors of(Brightness b) => b == Brightness.dark ? dark : light;

  /// Heatmap fill for a completion level from 0 to 1.
  Color heat(double level) => Color.lerp(surfaceMuted, primary, level.clamp(0.0, 1.0))!;

  /// Readable text color on top of [heat] at the same level.
  Color onHeat(double level) => level > 0.55 ? onPrimary : textPrimary;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) =>
      (other is AppColors && t >= 0.5) ? other : this;
}
