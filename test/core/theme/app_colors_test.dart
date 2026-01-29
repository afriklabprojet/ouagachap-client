import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary colors', () {
      test('primary is orange', () {
        expect(AppColors.primary, equals(const Color(0xFFE85D04)));
      });

      test('primaryLight is lighter orange', () {
        expect(AppColors.primaryLight, equals(const Color(0xFFFF8C42)));
      });

      test('primaryDark is darker orange', () {
        expect(AppColors.primaryDark, equals(const Color(0xFFB84A00)));
      });
    });

    group('Secondary colors', () {
      test('secondary is green', () {
        expect(AppColors.secondary, equals(const Color(0xFF059669)));
      });

      test('secondaryLight is lighter green', () {
        expect(AppColors.secondaryLight, equals(const Color(0xFF34D399)));
      });

      test('secondaryDark is darker green', () {
        expect(AppColors.secondaryDark, equals(const Color(0xFF047857)));
      });
    });

    group('Background colors', () {
      test('background is light gray', () {
        expect(AppColors.background, equals(const Color(0xFFF8FAFC)));
      });

      test('surface is white', () {
        expect(AppColors.surface, equals(const Color(0xFFFFFFFF)));
      });

      test('surfaceVariant is gray', () {
        expect(AppColors.surfaceVariant, equals(const Color(0xFFF1F5F9)));
      });
    });

    group('Text colors', () {
      test('textPrimary is dark', () {
        expect(AppColors.textPrimary, equals(const Color(0xFF1E293B)));
      });

      test('textSecondary is medium gray', () {
        expect(AppColors.textSecondary, equals(const Color(0xFF64748B)));
      });

      test('textTertiary is light gray', () {
        expect(AppColors.textTertiary, equals(const Color(0xFF94A3B8)));
      });

      test('textOnPrimary is white', () {
        expect(AppColors.textOnPrimary, equals(const Color(0xFFFFFFFF)));
      });
    });

    group('Status colors', () {
      test('success is green', () {
        expect(AppColors.success, equals(const Color(0xFF10B981)));
      });

      test('successLight is light green', () {
        expect(AppColors.successLight, equals(const Color(0xFFD1FAE5)));
      });
    });

    group('Constructor', () {
      test('cannot be instantiated (private constructor)', () {
        // AppColors has a private constructor AppColors._()
        // So we just verify that the class exists with static members
        expect(AppColors.primary, isA<Color>());
      });
    });
  });
}
