import 'package:flutter/material.dart';

/// House Finder palette — deep teal + warm coral on soft stone.
class AppColors {
  static const Color primary = Color(0xFF0B6E4F);
  static const Color primaryDark = Color(0xFF084C37);
  static const Color primaryLight = Color(0xFF149C6C);
  static const Color accent = Color(0xFFE85D4C);
  static const Color accentSoft = Color(0xFFFFE8E4);
  static const Color ink = Color(0xFF1A2332);
  static const Color inkMuted = Color(0xFF5B6574);
  static const Color surface = Color(0xFFF7F6F3);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4E2DC);
  static const Color success = Color(0xFF1B9E77);
  static const Color warning = Color(0xFFE6A23C);
  static const Color danger = Color(0xFFD64545);
  static const Color matchHigh = Color(0xFF0B6E4F);
  static const Color matchMid = Color(0xFFE6A23C);
  static const Color matchLow = Color(0xFF9AA3B2);
  static const Color chartBlue = Color(0xFF3D7EA6);
  static const Color chartTeal = Color(0xFF0B6E4F);
  static const Color chartCoral = Color(0xFFE85D4C);
  static const Color chartAmber = Color(0xFFE6A23C);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B6E4F), Color(0xFF0A4F5C), Color(0xFF1A2332)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8F5F0), Color(0xFFF7F6F3)],
  );
}
