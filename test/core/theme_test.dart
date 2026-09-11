import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

void main() {
  group('AppTheme tests', () {
    test(
        'Material 3 is enabled and palette matches maritime Vigo specification',
        () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);

      // Verify maritime Vigo palette tokens
      expect(theme.colorScheme.primary, equals(const Color(0xFF1B4965)));
      expect(theme.colorScheme.secondary, equals(const Color(0xFF62B6CB)));
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFFF4F1DE)));
      expect(theme.colorScheme.surface, equals(const Color(0xFFF4F1DE)));
    });

    test(
        'Typography enforces high legibility for adult educators (body >= 16sp)',
        () {
      final theme = AppTheme.lightTheme;
      final textTheme = theme.textTheme;

      expect(textTheme.bodyLarge?.fontSize, greaterThanOrEqualTo(16.0));
      expect(textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(16.0));

      expect(textTheme.titleLarge?.fontSize, greaterThanOrEqualTo(20.0));
      expect(textTheme.headlineMedium?.fontSize, greaterThanOrEqualTo(22.0));
    });
  });
}
