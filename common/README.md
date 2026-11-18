# common

Widgets, theme and configuration shared by the presentations in this
repository.

- `PresentationApp` wraps `FlutterDeckApp` with the shared theme, 1080p slide
  size, background, footer and slide margins.
- `Brand` holds the colors, the Outfit font and the JetBrains Mono font for code.
- `SlideCode`, `SqlCode`, `ComparisonCode`, `Terminal` and `InfoTile` are
  building blocks for slides.

```dart
import 'package:common/common.dart';

void main() => runApp(const PresentationApp(slides: [TitleSlide()]));
```
