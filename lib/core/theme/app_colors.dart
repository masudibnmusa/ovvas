import 'package:flutter/material.dart';

/// Habito color tokens. Screens read colors only from here (via
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
  });

  final Brightness brightness;

  /// Warm off-white page background.
  final Color background;

  /// Cards, sheets, inputs.
  final Color surface;

  /// Segmented controls, steppers, quiet fills.
  final Color surfaceMuted;

  /// Deep teal.
  final Color primary;
  final Color onPrimary;

  /// Soft mint accent.
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

  static const light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF5F6F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFECF2EF),
    primary: Color(0xFF1E6B5C),
    onPrimary: Color(0xFFFFFFFF),
    mint: Color(0xFFDDF1EA),
    onMint: Color(0xFF14503F),
    textPrimary: Color(0xFF15231F),
    textSecondary: Color(0xFF56645D),
    border: Color(0xFFDDE5E1),
    streak: Color(0xFFB87100),
    trendUp: Color(0xFF1E6B5C),
    trendDown: Color(0xFF636D68),
    danger: Color(0xFFB3261E),
    ringTrack: Color(0xFFE0EDE8),
    shadow: Color(0x12102A23),
  );

  static const dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF0D1E1A),
    surface: Color(0xFF152D27),
    surfaceMuted: Color(0xFF1B3832),
    primary: Color(0xFF5CC2A8),
    onPrimary: Color(0xFF032119),
    mint: Color(0xFF214B42),
    onMint: Color(0xFFC3EBDD),
    textPrimary: Color(0xFFE6F0EC),
    textSecondary: Color(0xFFA2B6AF),
    border: Color(0xFF27483F),
    streak: Color(0xFFF0B85A),
    trendUp: Color(0xFF5CC2A8),
    trendDown: Color(0xFF93A19C),
    danger: Color(0xFFF2857A),
    ringTrack: Color(0xFF223F38),
    shadow: Color(0x00000000),
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
