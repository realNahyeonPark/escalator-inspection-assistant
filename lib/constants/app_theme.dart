import 'package:flutter/material.dart';

/// 앱 공통 색상 (Figma 기준)
class AppColors {
  AppColors._();

  static const primary = Color(0xFF2563EB);
  static const background = Color(0xFFF5F6F8);
  static const surface = Colors.white;
  static const border = Color(0xFFE3E6EB);
  static const toggleBg = Color(0xFFE9EBEF);

  static const textPrimary = Color(0xFF1A1D23);
  static const textSecondary = Color(0xFF8A9099);

  static const scannerBg = Color(0xFF2B2F36);

  // 상태 배지
  static const normal = Color(0xFF16A34A);
  static const normalBg = Color(0xFFE7F6EC);
  static const warning = Color(0xFFEA580C);
  static const warningBg = Color(0xFFFDEEE3);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFDE8E8);
  static const primaryBg = Color(0xFFE8EFFD);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        splashFactory: InkSparkle.splashFactory,
      );
}
