import 'package:material_ui/material_ui.dart';

import 'colors.dart';

/// Builds HomeCoffee's ThemeData.
///
/// Khmer stacks vowels and subscript consonants above and below the line, so
/// Khmer gets taller lines (1.7 for body text, 1.55 for headings) than
/// English (1.45 and 1.25). Nothing gets clipped.
abstract final class HomeCoffeeTheme {
  static const fontPackage = 'homecoffee_ui';
  static const minTouchTarget = 48.0;

  static ThemeData light({String language = 'en'}) =>
      _build(HomeCoffeeColors.light, HomeCoffeeExtras.light, language);

  static ThemeData dark({String language = 'en'}) =>
      _build(HomeCoffeeColors.dark, HomeCoffeeExtras.dark, language);

  static TextTheme textTheme({String language = 'en'}) {
    final khmer = language == 'km';
    final body = khmer ? 1.7 : 1.45;
    final heading = khmer ? 1.55 : 1.25;
    TextStyle style(double size, FontWeight weight, double height) =>
        TextStyle(fontSize: size, fontWeight: weight, height: height);
    // Sizes from Foundations. Flutter treats them as sp, so text grows with
    // the phone's text size setting.
    return TextTheme(
      headlineMedium: style(28, FontWeight.w700, heading),
      titleLarge: style(22, FontWeight.w700, heading),
      titleMedium: style(17, FontWeight.w700, heading),
      bodyLarge: style(16, FontWeight.w400, body),
      bodyMedium: style(14, FontWeight.w400, body),
      labelLarge: style(14, FontWeight.w700, heading),
      labelMedium: style(12, FontWeight.w500, body),
    );
  }

  static ThemeData _build(
    ColorScheme scheme,
    HomeCoffeeExtras extras,
    String language,
  ) {
    const buttonSize = Size(minTouchTarget, minTouchTarget);
    const pill = StadiumBorder();
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Figtree',
      // Khmer characters aren't in Figtree, so they fall back per character.
      fontFamilyFallback: const ['NotoSansKhmer'],
      package: fontPackage,
      textTheme: textTheme(language: language),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [extras],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, shape: pill),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: pill,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: buttonSize),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
