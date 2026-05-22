import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/theme/app_colors.dart';
import 'package:coffee_recommender/core/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('Light theme properties are configured correctly', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.lightPrimary);
      expect(theme.colorScheme.secondary, AppColors.lightAccent);
      expect(theme.colorScheme.background, AppColors.lightBg);
    });

    test('Dark theme properties are configured correctly', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.darkPrimary);
      expect(theme.colorScheme.secondary, AppColors.darkAccent);
      expect(theme.colorScheme.background, AppColors.darkBg);
    });
  });
}
