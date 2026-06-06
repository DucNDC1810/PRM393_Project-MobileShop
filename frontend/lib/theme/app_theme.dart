import 'package:flutter/material.dart';

class AppColors {
  // Sleek tech blue/indigo color palette
  static const primary = Color(0xFF0F62FE); // Vibrant Tech Blue
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1E3A8A); // Deep Navy
  static const onPrimaryContainer = Color(0xFFFFFFFF);
  static const primaryFixed = Color(0xFFD8E4FF);
  static const primaryFixedDim = Color(0xFFADC8FF);
  static const inversePrimary = Color(0xFFADC8FF);

  static const secondary = Color(0xFF475569); // Slate Grey
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE2E8F0);
  static const onSecondaryContainer = Color(0xFF1E293B);
  static const secondaryFixed = Color(0xFFE2E8F0);
  static const secondaryFixedDim = Color(0xFFCBD5E1);

  static const tertiary = Color(0xFF0EA5E9); // Sky Blue
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF0369A1);
  static const onTertiaryContainer = Color(0xFFFFFFFF);
  static const tertiaryFixed = Color(0xFFE0F2FE);
  static const tertiaryFixedDim = Color(0xFFBAE6FD);

  static const error = Color(0xFFEF4444);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onErrorContainer = Color(0xFF991B1B);

  static const background = Color(0xFFF8FAFC); // Very light slate blue-grey
  static const onBackground = Color(0xFF0F172A); // Dark slate
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF0F172A);
  static const surfaceVariant = Color(0xFFE2E8F0);
  static const onSurfaceVariant = Color(0xFF475569);
  static const surfaceDim = Color(0xFFF1F5F9);
  static const surfaceBright = Color(0xFFF8FAFC);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F5F9);
  static const surfaceContainer = Color(0xFFE2E8F0);
  static const surfaceContainerHigh = Color(0xFFCBD5E1);
  static const surfaceContainerHighest = Color(0xFF94A3B8);

  static const outline = Color(0xFF94A3B8);
  static const outlineVariant = Color(0xFFCBD5E1);
  static const inverseSurface = Color(0xFF1E293B);
  static const inverseOnSurface = Color(0xFFF8FAFC);
  static const surfaceTint = Color(0xFF0F62FE);

  static const success = Color(0xFF10B981); // Emerald Green
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.inverseOnSurface,
          inversePrimary: AppColors.inversePrimary,
          surfaceTint: AppColors.surfaceTint,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'DM Sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 1,
          shadowColor: Colors.black12,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
      );
}
