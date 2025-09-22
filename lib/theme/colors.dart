import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF0A1E40); // deep navy
  static const Color secondary = Color(0xFF1E3A8A); // indigo
  static const Color tertiary = Color(0xFF152A51); // mid-navy

  // Functional
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Surfaces / Text
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF7F8FA);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // App gradient used across screens
  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, tertiary, secondary],
  );
}
