import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses Material 3 and light brightness', () {
      final theme = AppTheme.light;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark theme uses Material 3 and dark brightness', () {
      final theme = AppTheme.dark;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('light and dark themes use distinct backgrounds', () {
      expect(
        AppTheme.light.scaffoldBackgroundColor,
        isNot(AppTheme.dark.scaffoldBackgroundColor),
      );
    });

    test('cards and buttons use rounded shapes, not sharp corners', () {
      final cardShape = AppTheme.light.cardTheme.shape;

      expect(cardShape, isA<RoundedRectangleBorder>());
      final borderRadius =
          (cardShape as RoundedRectangleBorder).borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, greaterThan(0));
    });
  });
}
