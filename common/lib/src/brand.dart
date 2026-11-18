// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// The Supabase colors and font shared by the presentations.
abstract final class Brand {
  static const fontFamily = 'packages/common/Outfit';

  static const green = Color(0xFF3ECF8E);
  static const red = Color(0xFFF2777A);
  static const background = Color(0xFF1C1C1C);
  static const surface = Color(0xFF2A2A2A);
  static const surfaceHigh = Color(0xFF353535);
  static const text = Color(0xFFEDEDED);
  static const mutedText = Color(0xFFA0A0A0);

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: Brightness.dark,
      primary: green,
      surface: background,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      useMaterial3: true,
    );
  }
}
