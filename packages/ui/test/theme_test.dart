import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:homecoffee_ui/homecoffee_ui.dart';
import 'package:material_ui/material_ui.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, scheme, extras) in [
    ('light', HomeCoffeeColors.light, HomeCoffeeExtras.light),
    ('dark', HomeCoffeeColors.dark, HomeCoffeeExtras.dark),
  ]) {
    group('$name colours pass WCAG AA', () {
      final textPairs = {
        'text on surface': (scheme.onSurface, scheme.surface),
        'secondary text on surface': (scheme.onSurfaceVariant, scheme.surface),
        'description text on surface': (extras.bodyText, scheme.surface),
        'text on cards': (scheme.onSurface, scheme.surfaceContainerHighest),
        'buttons': (scheme.onPrimary, scheme.primary),
        'points card': (scheme.onPrimaryContainer, scheme.primaryContainer),
        'chips': (scheme.onSecondaryContainer, scheme.secondaryContainer),
        'ready badge': (scheme.onTertiaryContainer, scheme.tertiaryContainer),
        'links and prices': (scheme.primary, scheme.surface),
        'field errors': (scheme.error, scheme.surface),
        'snackbar': (scheme.onInverseSurface, scheme.inverseSurface),
      };
      textPairs.forEach((label, pair) {
        test('$label is at least 4.5:1', () {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
        });
      });
      test('borders are at least 3:1', () {
        expect(
          contrast(scheme.outline, scheme.surface),
          greaterThanOrEqualTo(3),
        );
      });
    });
  }

  test('Khmer gets taller lines than English', () {
    final en = HomeCoffeeTheme.textTheme();
    final km = HomeCoffeeTheme.textTheme(language: 'km');
    expect(en.bodyLarge!.height, 1.45);
    expect(km.bodyLarge!.height, 1.7);
    expect(km.titleLarge!.height, 1.55);
  });

  test('themes use Figtree with Noto Sans Khmer as the fallback', () {
    final theme = HomeCoffeeTheme.light();
    expect(
      theme.textTheme.bodyLarge!.fontFamily,
      'packages/homecoffee_ui/Figtree',
    );
    expect(
      theme.textTheme.bodyLarge!.fontFamilyFallback,
      contains('packages/homecoffee_ui/NotoSansKhmer'),
    );
    expect(
      HomeCoffeeTheme.dark().colorScheme.surface,
      HomeCoffeeColors.dark.surface,
    );
  });
}
