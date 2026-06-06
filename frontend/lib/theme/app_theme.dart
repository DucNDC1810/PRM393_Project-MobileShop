import 'package:flutter/material.dart';

class AppColors {
  // Beauty & Glow pink blush and rose gold/pink luxury palette
  static const primary = Color(0xFFD1557A); // Beautiful brand rose pink
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFCDCE5); // Soft blush pink container
  static const onPrimaryContainer = Color(0xFF520E22); // Dark rose/plum text
  static const primaryFixed = Color(0xFFFDEAF0); // Very light blush
  static const primaryFixedDim = Color(0xFFFADAE5);
  static const inversePrimary = Color(0xFFFADAE5);

  static const secondary = Color(0xFF665C61); // Muted Plum/Slate
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFEADCE2);
  static const onSecondaryContainer = Color(0xFF6A6065);
  static const secondaryFixed = Color(0xFFEDDFE5);
  static const secondaryFixedDim = Color(0xFFD1C3C9);

  static const tertiary = Color(0xFF605E5D);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFA29F9D);
  static const onTertiaryContainer = Color(0xFF383635);
  static const tertiaryFixed = Color(0xFFE6E1E0);
  static const tertiaryFixedDim = Color(0xFFCAC6C4);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Background is soft blush pink floor matching the brand
  static const background = Color(0xFFF9EAF0); // Blush Pink Floor
  static const onBackground = Color(0xFF1B1C1A);
  static const surface = Color(0xFFFFFAF8); // Cream White Surface
  static const onSurface = Color(0xFF1B1C1A);
  static const surfaceVariant = Color(0xFFE5E2DF);
  static const onSurfaceVariant = Color(0xFF51443C);
  static const surfaceDim = Color(0xFFDCDAD6);
  static const surfaceBright = Color(0xFFFCF9F5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F3F0);
  static const surfaceContainer = Color(0xFFF0EDEA);
  static const surfaceContainerHigh = Color(0xFFEAE8E4);
  static const surfaceContainerHighest = Color(0xFFE5E2DF);

  static const outline = Color(0xFF83746B);
  static const outlineVariant = Color(0xFFD5C3B8);
  static const inverseSurface = Color(0xFF30302E);
  static const inverseOnSurface = Color(0xFFF3F0ED);
  static const surfaceTint = Color(0xFFD1557A);

  static const success = Color(0xFF065F46); // Emerald Green for completed status
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
