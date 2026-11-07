import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds Material theme data from Habito tokens.
/// Type scale: 12, 14, 16, 20, 24, 32. Cards use a 20 radius.
ThemeData buildTheme(AppColors c) {
  final isDark = c.brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: c.brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.mint,
    onPrimaryContainer: c.onMint,
    secondary: c.primary,
    onSecondary: c.onPrimary,
    secondaryContainer: c.mint,
    onSecondaryContainer: c.onMint,
    error: c.danger,
    onError: isDark ? Colors.black : Colors.white,
    surface: c.surface,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    outline: c.border,
    outlineVariant: c.border,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface,
    surfaceContainerHighest: c.surfaceMuted,
    inverseSurface: c.textPrimary,
    onInverseSurface: c.background,
    shadow: Colors.black,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final t = base.textTheme;
  // Keep each style's font family; only change size, weight and spacing.
  TextStyle style(TextStyle? from, double size, FontWeight weight, {double? height, double? spacing}) =>
      from!.copyWith(fontSize: size, fontWeight: weight, height: height, letterSpacing: spacing);
  final text = t
      .copyWith(
        headlineMedium: style(t.headlineMedium, 32, FontWeight.w700, height: 1.15, spacing: -0.5),
        headlineSmall: style(t.headlineSmall, 24, FontWeight.w700, height: 1.25, spacing: -0.3),
        titleLarge: style(t.titleLarge, 20, FontWeight.w700, height: 1.3, spacing: 0),
        titleMedium: style(t.titleMedium, 16, FontWeight.w600, height: 1.35, spacing: 0),
        bodyLarge: style(t.bodyLarge, 16, FontWeight.w400, height: 1.45, spacing: 0),
        bodyMedium: style(t.bodyMedium, 14, FontWeight.w400, height: 1.45, spacing: 0),
        bodySmall: style(t.bodySmall, 12, FontWeight.w400, height: 1.4, spacing: 0),
        labelLarge: style(t.labelLarge, 14, FontWeight.w600),
        labelMedium: style(t.labelMedium, 12, FontWeight.w600),
      )
      .apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

  final rounded14 = BorderRadius.circular(14);

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    textTheme: text,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.mint,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        final selected = s.contains(WidgetState.selected);
        return text.labelMedium!.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? c.textPrimary : c.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? c.onMint : c.textSecondary,
          )),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      shape: const CircleBorder(),
      elevation: 2,
      highlightElevation: 4,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: const Size(64, 56),
        shape: const StadiumBorder(),
        textStyle: text.labelLarge!.copyWith(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(64, 48),
        shape: const StadiumBorder(),
        side: BorderSide(color: c.border, width: 1.5),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: text.bodyLarge!.copyWith(color: c.textSecondary),
      border: OutlineInputBorder(borderRadius: rounded14, borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(borderRadius: rounded14, borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(borderRadius: rounded14, borderSide: BorderSide(color: c.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: rounded14, borderSide: BorderSide(color: c.danger)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: rounded14, borderSide: BorderSide(color: c.danger, width: 2)),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceMuted,
      selectedColor: c.mint,
      checkmarkColor: c.onMint,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: text.bodyMedium!.copyWith(color: c.textPrimary, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: c.textSecondary,
      textColor: c.textPrimary,
      minVerticalPadding: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodyMedium!.copyWith(color: c.textSecondary),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.transparent : c.border,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.ringTrack,
      circularTrackColor: c.ringTrack,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.textPrimary,
      contentTextStyle: text.bodyMedium!.copyWith(color: c.background),
      actionTextColor: isDark ? AppColors.light.primary : AppColors.dark.primary,
      shape: RoundedRectangleBorder(borderRadius: rounded14),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.border,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: rounded14),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.primary,
      inactiveTrackColor: c.ringTrack,
      thumbColor: c.primary,
    ),
    timePickerTheme: TimePickerThemeData(backgroundColor: c.surface),
    datePickerTheme: DatePickerThemeData(backgroundColor: c.surface, surfaceTintColor: Colors.transparent),
  );
}
