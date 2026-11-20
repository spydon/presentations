import 'package:flutter_deck/flutter_deck.dart';
import 'package:material_ui/material_ui.dart';
import 'package:common/src/brand.dart';

/// A code listing sized for a 1080p slide.
class SlideCode extends StatelessWidget {
  const SlideCode({
    required this.code,
    this.fileName,
    this.language = 'dart',
    this.highlightedLines = const [],
    this.fontSize = 28,
    super.key,
  });

  final String code;
  final String? fileName;
  final String language;

  /// Zero-indexed lines to highlight, dimming the rest.
  final List<int> highlightedLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FlutterDeckCodeHighlightTheme(
      data: FlutterDeckCodeHighlightTheme.of(context).copyWith(
        backgroundColor: Brand.surface,
        textStyle: TextStyle(
          fontFamily: Brand.monospaceFontFamily,
          fontSize: fontSize,
          height: 1.4,
        ),
      ),
      child: FlutterDeckCodeHighlight(
        code: code,
        fileName: fileName,
        language: language,
        highlightedLines: highlightedLines,
      ),
    );
  }
}
