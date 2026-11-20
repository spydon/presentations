import 'package:material_ui/material_ui.dart';

/// The Supabase colors and the fonts shared by the presentations, and a theme
/// for both the slides and the pages the audience opens on their phones.
abstract final class Brand {
  static const fontFamily = 'packages/common/Outfit';
  static const monospaceFontFamily = 'packages/common/JetBrainsMono';

  static const green = Color(0xFF3ECF8E);
  static const red = Color(0xFFF2777A);
  static const background = Color(0xFF1C1C1C);
  static const surface = Color(0xFF2A2A2A);
  static const surfaceHigh = Color(0xFF353535);
  static const text = Color(0xFFEDEDED);
  static const mutedText = Color(0xFFA0A0A0);

  /// The box of a card on a slide, such as an [InfoTile].
  ///
  /// A [highlighted] card gets a thick green border and a soft green glow,
  /// and the text keeps its colors. The border is drawn outside the card, so
  /// that its width does not move the content when the highlight changes.
  static BoxDecoration card({bool highlighted = false}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted ? green : surfaceHigh,
      width: highlighted ? 3 : 1,
      strokeAlign: BorderSide.strokeAlignOutside,
    ),
    boxShadow: [
      BoxShadow(
        color: green.withValues(alpha: highlighted ? 0.2 : 0),
        blurRadius: 40,
      ),
    ],
  );

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
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: green,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: green),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
