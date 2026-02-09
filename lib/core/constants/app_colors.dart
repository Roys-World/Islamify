import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color primary = Color(0xFF1E7F5C); // Islamic green
  static const Color primary1 = Color(0xFF1B5E20); // Deep Islamic green
  static const Color secondary = Color(0xFF0D6B47); // Dark Islamic green
  static const Color tertiary = Color(0xFF2D9B6E); // Lighter Islamic green
  static const Color background = Color(0xFFF7F4EF); // Warm cream
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color border = Color(0xFFE5E7EB);
  static const Color card = Colors.white;

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0A0E27); // Deep dark blue-black
  static const Color darkSurface = Color(0xFF1A1F3A); // Dark surface
  static const Color darkCard = Color(0xFF242E4A); // Dark card background
  static const Color darkTextPrimary = Color(0xFFE8E8E8); // Light text
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Light gray text
  static const Color darkBorder = Color(0xFF3A4558); // Dark border

  // Dark Mode Primary Colors (darker shade for dark theme)
  static const Color darkPrimary = Color(
    0xFF2ECC71,
  ); // Lighter green for dark mode
  static const Color darkPrimary1 = Color(0xFF27AE60); // Adjusted green
  static const Color darkSecondary = Color(0xFF16A085); // Adjusted teal
  static const Color darkTertiary = Color(0xFF48C9B0); // Lighter teal

  /// Get adaptive colors based on dark mode
  static Color getPrimaryColor(bool isDarkMode) =>
      isDarkMode ? darkPrimary : primary;

  static Color getPrimary1Color(bool isDarkMode) =>
      isDarkMode ? darkPrimary1 : primary1;

  static Color getSecondaryColor(bool isDarkMode) =>
      isDarkMode ? darkSecondary : secondary;

  static Color getTertiaryColor(bool isDarkMode) =>
      isDarkMode ? darkTertiary : tertiary;

  static Color getBackgroundColor(bool isDarkMode) =>
      isDarkMode ? darkBackground : background;

  static Color getSurfaceColor(bool isDarkMode) =>
      isDarkMode ? darkSurface : surface;

  static Color getCardColor(bool isDarkMode) => isDarkMode ? darkCard : card;

  static Color getTextPrimaryColor(bool isDarkMode) =>
      isDarkMode ? darkTextPrimary : textPrimary;

  static Color getTextSecondaryColor(bool isDarkMode) =>
      isDarkMode ? darkTextSecondary : textSecondary;

  static Color getBorderColor(bool isDarkMode) =>
      isDarkMode ? darkBorder : border;
}
