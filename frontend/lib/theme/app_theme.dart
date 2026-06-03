import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFAC254F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFCD4066);
  static const onPrimaryContainer = Color(0xFFFFFBFF);
  static const primaryFixed = Color(0xFFFFD9DE);
  static const primaryFixedDim = Color(0xFFFFB2BF);
  static const inversePrimary = Color(0xFFFFB2BF);

  static const secondary = Color(0xFF635E54);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE9E2D5);
  static const onSecondaryContainer = Color(0xFF69645A);
  static const secondaryFixed = Color(0xFFE9E2D5);
  static const secondaryFixedDim = Color(0xFFCDC6B9);

  static const tertiary = Color(0xFF715825);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF8C713B);
  static const onTertiaryContainer = Color(0xFFFFFBFF);
  static const tertiaryFixed = Color(0xFFFFDEA4);
  static const tertiaryFixedDim = Color(0xFFE4C285);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFFFF8F7);
  static const onBackground = Color(0xFF281717);
  static const surface = Color(0xFFFFF8F7);
  static const onSurface = Color(0xFF281717);
  static const surfaceVariant = Color(0xFFFCDBDA);
  static const onSurfaceVariant = Color(0xFF584144);
  static const surfaceDim = Color(0xFFF3D3D2);
  static const surfaceBright = Color(0xFFFFF8F7);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFFF0EF);
  static const surfaceContainer = Color(0xFFFFE9E8);
  static const surfaceContainerHigh = Color(0xFFFFE1E0);
  static const surfaceContainerHighest = Color(0xFFFCDBDA);

  static const outline = Color(0xFF8B7074);
  static const outlineVariant = Color(0xFFDFBFC3);
  static const inverseSurface = Color(0xFF3F2B2B);
  static const inverseOnSurface = Color(0xFFFFEDEC);
  static const surfaceTint = Color(0xFFAF2851);

  static const success = Color(0xFF2E7D32);
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
            fontFamily: 'Playfair Display',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
      );
}
