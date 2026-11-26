import 'package:material_ui/material_ui.dart';

/// Colour roles from the prototype (seed #7B4B2A). Every text pair passes
/// WCAG AA 4.5:1, and outlines pass 3:1. test/contrast_test.dart checks it.
abstract final class HomeCoffeeColors {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF7B4B2A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFDCC7),
    onPrimaryContainer: Color(0xFF311300),
    secondary: Color(0xFF765947),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF6DED0),
    onSecondaryContainer: Color(0xFF2B160A),
    // Green only ever means "ready" or "applied".
    tertiary: Color(0xFF0B6B4A),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFA6F2CC),
    onTertiaryContainer: Color(0xFF002114),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFFF8F5),
    onSurface: Color(0xFF201A18),
    onSurfaceVariant: Color(0xFF51443C),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFDF1EC),
    surfaceContainer: Color(0xFFF7ECE6),
    surfaceContainerHigh: Color(0xFFF1E6E1),
    surfaceContainerHighest: Color(0xFFECE0DB),
    outline: Color(0xFF84746B),
    outlineVariant: Color(0xFFD6C3B8),
    inverseSurface: Color(0xFF352F2C),
    onInverseSurface: Color(0xFFFAEEE9),
    inversePrimary: Color(0xFFFAB88F),
  );

  /// Warm espresso brown, not the website's blue-grey.
  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFAB88F),
    onPrimary: Color(0xFF4D2608),
    primaryContainer: Color(0xFF6A3B1C),
    onPrimaryContainer: Color(0xFFFFDCC7),
    secondary: Color(0xFFE5BFA9),
    onSecondary: Color(0xFF432B1D),
    secondaryContainer: Color(0xFF5A4232),
    onSecondaryContainer: Color(0xFFFDDCC8),
    tertiary: Color(0xFF84D7B0),
    onTertiary: Color(0xFF003825),
    tertiaryContainer: Color(0xFF005138),
    onTertiaryContainer: Color(0xFFA6F2CC),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF171210),
    onSurface: Color(0xFFECE0DB),
    onSurfaceVariant: Color(0xFFD6C3B8),
    surfaceContainerLowest: Color(0xFF120D0B),
    surfaceContainerLow: Color(0xFF201A18),
    surfaceContainer: Color(0xFF241E1B),
    surfaceContainerHigh: Color(0xFF2F2926),
    surfaceContainerHighest: Color(0xFF3A3330),
    outline: Color(0xFF9E8D84),
    outlineVariant: Color(0xFF51443C),
    inverseSurface: Color(0xFFECE0DB),
    onInverseSurface: Color(0xFF352F2C),
    inversePrimary: Color(0xFF7B4B2A),
  );
}

/// Colours the prototype uses that have no Material role.
@immutable
class HomeCoffeeExtras extends ThemeExtension<HomeCoffeeExtras> {
  const HomeCoffeeExtras({required this.bodyText, required this.favourite});

  /// Description text: darker than onSurfaceVariant, so it stays readable.
  final Color bodyText;

  /// The filled heart on favourites.
  final Color favourite;

  static const light = HomeCoffeeExtras(
    bodyText: Color(0xFF3D322B),
    favourite: Color(0xFFC0254A),
  );
  static const dark = HomeCoffeeExtras(
    bodyText: Color(0xFFE6D8CF),
    favourite: Color(0xFFFF8FA6),
  );

  @override
  HomeCoffeeExtras copyWith({Color? bodyText, Color? favourite}) =>
      HomeCoffeeExtras(
        bodyText: bodyText ?? this.bodyText,
        favourite: favourite ?? this.favourite,
      );

  @override
  HomeCoffeeExtras lerp(HomeCoffeeExtras? other, double t) => other == null
      ? this
      : HomeCoffeeExtras(
          bodyText: Color.lerp(bodyText, other.bodyText, t)!,
          favourite: Color.lerp(favourite, other.favourite, t)!,
        );
}
