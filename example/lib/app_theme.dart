import 'package:flutter/material.dart';

class AppTheme {
  static Color primaryColor = Colors.green;
  static Color secondaryColor = Colors.green;
  // Light theme
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
    );

    return ThemeData(
      colorScheme: colorScheme,

      // Typography
      //textTheme: GoogleFonts.poppinsTextTheme(),
      // Apply Inter font to body text
      //primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      // Other theme settings
    );
  }

  // Dark theme with primarized surfaces
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      // onPrimary: Colors.white,
      secondary: secondaryColor,

      // onPrimary: AppColors.onPrimaryDark,
      // primary: AppColors.primary,
    );

    return ThemeData(
      colorScheme: colorScheme,

      // Typography
      // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      // primaryTextTheme:
      //     GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      // Other theme settings
    );
  }
}
