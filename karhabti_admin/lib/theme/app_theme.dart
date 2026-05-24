import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales pour l'application CARHABTI
  static const Color primaryColor = Color(0xFF3F51B5); // Bleu principal
  static const Color secondaryColor = Color(0xFF5C6BC0); // Turquoise
  static const Color accentColor = Color(0xFF738FFE); // Orange accent
  static const Color dangerColor = Color(
    0xFFE53935,
  ); // Rouge pour les erreurs/alertes
  static const Color successColor = Color(0xFF4CAF50); // Vert pour les succès
  static const Color warningColor = Color(
    0xFFFFC107,
  ); // Jaune pour les avertissements

  // Couleurs neutres
  static const Color darkColor = Color(0xFF212121); // Presque noir
  static const Color greyColor = Color(0xFF757575); // Gris principal
  static const Color lightGreyColor = Color(0xFFE0E0E0); // Gris clair
  static const Color backgroundColor = Color(0xFFF5F5F5); // Fond d'écran
  static const Color whiteColor = Color(0xFFFFFFFF); // Blanc

  // Ombres pour les cartes et élévations
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      // ignore: deprecated_member_use
      color: darkColor.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Rayons d'arrondi
  static const double borderRadius = 10.0;
  static const double buttonRadius = 8.0;

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: whiteColor,
      error: dangerColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: whiteColor,
      foregroundColor: darkColor,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: whiteColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    iconTheme: const IconThemeData(color: greyColor),
    dividerTheme: const DividerThemeData(color: lightGreyColor),
    scaffoldBackgroundColor: backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: whiteColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: lightGreyColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: lightGreyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(lightGreyColor),
      dividerThickness: 1,
    ),
  );

  // Styles de texte communs
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: darkColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkColor,
  );

  static const TextStyle bodyLarge = TextStyle(fontSize: 16, color: darkColor);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14, color: darkColor);

  static const TextStyle caption = TextStyle(fontSize: 12, color: greyColor);
}
