# common

Widgets, theme and configuration shared by the presentations in this
repository.

- `PresentationApp` wraps `FlutterDeckApp` with the shared theme, 1080p slide
  size, background, footer and slide margins.
- `Brand` holds the colors, the Outfit font and the JetBrains Mono font for code,
  and a theme that also styles the forms of pages the audience opens on their
  phones.
- `SlideCode`, `SqlCode`, `ComparisonCode`, `Terminal`, `InfoTile`, `Pill`,
  `NumberedStep` and `SteppedBulletList` are building blocks for slides.
- `PopIn`, `AnimatedReorderColumn` and `ConfettiBurst` animate live content,
  such as questions from the audience.

```dart
import 'package:common/common.dart';

void main() => runApp(const PresentationApp(slides: [TitleSlide()]));
```
