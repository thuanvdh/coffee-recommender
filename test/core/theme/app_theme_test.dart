import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/theme/app_colors.dart';
import 'package:coffee_recommender/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppTheme Tests', () {
    testWidgets('Light theme properties are configured correctly',
        (WidgetTester tester) async {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.lightPrimary);
      expect(theme.colorScheme.secondary, AppColors.lightAccent);
      expect(theme.colorScheme.surface, AppColors.lightBg);
    });

    testWidgets('Dark theme properties are configured correctly',
        (WidgetTester tester) async {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.darkPrimary);
      expect(theme.colorScheme.secondary, AppColors.darkAccent);
      expect(theme.colorScheme.surface, AppColors.darkBg);
    });
  });
}
