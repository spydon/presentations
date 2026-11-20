import 'package:flutter_deck/flutter_deck.dart';
import 'package:material_ui/material_ui.dart';

/// Margins of the slide content, wider than the 16 pixels flutter_deck uses so
/// that text does not hug the edges of the projected slide.
abstract final class DeckInsets {
  static const horizontal = 96.0;

  static const header = EdgeInsets.fromLTRB(horizontal, 48, horizontal, 8);
  static const content = EdgeInsets.fromLTRB(horizontal, 24, horizontal, 32);
  static const footer = EdgeInsets.symmetric(
    horizontal: horizontal - 16,
    vertical: 8,
  );

  static const splitGap = 64.0;
}

/// Applies [DeckInsets] to the blank, split and template slides, and lines the
/// header up with the content below it.
final deckTemplateOverrides = FlutterDeckTemplateOverrideConfiguration(
  blankSlideBuilder:
      (context, builder, backgroundBuilder, footerBuilder, headerBuilder) =>
          _DeckSlide(
            backgroundBuilder: backgroundBuilder,
            footerBuilder: footerBuilder,
            headerBuilder: headerBuilder,
            content: (context) =>
                Padding(padding: DeckInsets.content, child: builder(context)),
          ),
  templateSlideBuilder:
      (
        context,
        backgroundBuilder,
        contentBuilder,
        footerBuilder,
        headerBuilder,
      ) => _DeckSlide(
        backgroundBuilder: backgroundBuilder,
        footerBuilder: footerBuilder,
        headerBuilder: headerBuilder,
        content: (context) => Padding(
          padding: DeckInsets.content,
          child: contentBuilder?.call(context) ?? const SizedBox.shrink(),
        ),
      ),
  splitSlideBuilder:
      (
        context,
        leftBuilder,
        rightBuilder,
        backgroundBuilder,
        footerBuilder,
        headerBuilder,
        splitRatio,
      ) {
        final ratio = splitRatio ?? const SplitSlideRatio();
        return _DeckSlide(
          backgroundBuilder: backgroundBuilder,
          footerBuilder: footerBuilder,
          headerBuilder: headerBuilder,
          content: (context) => Padding(
            padding: DeckInsets.content,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: ratio.left, child: leftBuilder(context)),
                const SizedBox(width: DeckInsets.splitGap),
                Expanded(flex: ratio.right, child: rightBuilder(context)),
              ],
            ),
          ),
        );
      },
);

class _DeckSlide extends StatelessWidget {
  const _DeckSlide({
    required this.content,
    this.backgroundBuilder,
    this.footerBuilder,
    this.headerBuilder,
  });

  final WidgetBuilder content;
  final WidgetBuilder? backgroundBuilder;
  final WidgetBuilder? footerBuilder;
  final WidgetBuilder? headerBuilder;

  @override
  Widget build(BuildContext context) {
    final FlutterDeckSlideConfiguration(footer: footer, header: header) =
        context.flutterDeck.configuration;
    return FlutterDeckSlideBase(
      backgroundBuilder: backgroundBuilder,
      contentBuilder: content,
      headerBuilder: header.showHeader
          ? headerBuilder ?? (_) => _Header(title: header.title)
          : null,
      footerBuilder: footer.showFooter
          ? footerBuilder ??
                (_) => Padding(
                  padding: DeckInsets.footer,
                  child: FlutterDeckFooter.fromConfiguration(
                    configuration: footer,
                  ),
                )
          : null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterDeckHeaderTheme.of(context);
    return Padding(
      padding: DeckInsets.header,
      child: Text(title, style: theme.textStyle?.copyWith(color: theme.color)),
    );
  }
}
