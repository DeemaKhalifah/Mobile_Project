import 'package:flutter/material.dart';

class AppStyles {
  // Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color primaryDarkColor = Color(0xFF1565C0);
  static Color primaryLightColor = Colors.blue[800]!;
  static Color primaryVeryDarkColor = Colors.blue[900]!;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color backgroundColorAlt = Color(0xFFF5F7FA);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static Color blue50 = Colors.blue[50]!;
  static Color blue700 = Colors.blue[700]!;
  static Color blue600 = Colors.blue[600]!;
  static const Color white70 = Colors.white70;
  static const Color accentColor = Colors.blueAccent;

  // Text Styles
  static const TextStyle welcomeTitleStyle = TextStyle(
    fontSize: 24,
    color: whiteColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle serviceNameStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle servicePriceStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: whiteColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: white70,
  );

  static const TextStyle priceStyle = TextStyle(
    fontSize: 20,
    color: white70,
  );

  static const TextStyle walletBalanceStyle = TextStyle(
    color: whiteColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle walletBalanceLargeStyle = TextStyle(
    color: whiteColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: whiteColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonTextStyle16 = TextStyle(
    fontSize: 16,
  );

  static const TextStyle roleTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blueAccent,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
      );

  static ButtonStyle get primaryButtonStyleRounded => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  static ButtonStyle get whiteButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

  static ButtonStyle get darkButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryVeryDarkColor,
        foregroundColor: whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      );

  static ButtonStyle get whiteRoundedButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        foregroundColor: primaryVeryDarkColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      );

  static ButtonStyle get walletButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        foregroundColor: primaryVeryDarkColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      );

  // Input Decoration
  static InputDecoration get standardInputDecoration => const InputDecoration(
        border: OutlineInputBorder(),
      );

  static InputDecoration get filledInputDecoration => InputDecoration(
        filled: true,
        fillColor: blue50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  // Box Decorations
  static BoxDecoration get roleBoxDecoration => BoxDecoration(
        color: blue50,
        borderRadius: BorderRadius.circular(8),
      );

  static BoxDecoration get cardBoxDecoration => BoxDecoration(
        color: blue600,
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration get balanceBoxDecoration => BoxDecoration(
        color: blue700,
        borderRadius: BorderRadius.circular(12),
      );

  // Card Styles
  static ShapeBorder get cardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      );

  static BorderRadius get cardTopBorderRadius => const BorderRadius.vertical(
        top: Radius.circular(10),
      );

  // Spacing
  static const double standardPadding = 20.0;
  static const double standardPadding16 = 16.0;
  static const double standardPadding10 = 10.0;
  static const double smallSpacing = 10.0;
  static const double mediumSpacing = 15.0;
  static const double largeSpacing = 20.0;
  static const double xlargeSpacing = 30.0;
  static const double xlargeSpacing40 = 40.0;
  static const double imageHeight = 180.0;

  // Sizes
  static const double borderRadius10 = 10.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius25 = 25.0;
  static const double iconSize = 60.0;
}

