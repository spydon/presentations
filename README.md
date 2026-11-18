# Presentations

Slide decks built with [flutter_deck](https://pub.dev/packages/flutter_deck),
one Flutter project per directory, published at
<https://presentations.spydon.dev/>.

| Directory                                    | Talk                              | Length    |
| -------------------------------------------- | --------------------------------- | --------- |
| [`supabase_flutter_v3`](supabase_flutter_v3) | What's new in supabase_flutter v3 | 2 minutes |
| [`supabase_py_v3`](supabase_py_v3)           | What's new in supabase-py v3      | 2 minutes |

## Shared code

[`common`](common) holds the widgets, theme and configuration shared by the
presentations, such as `PresentationApp`, `Brand`, `SlideCode` and `Terminal`.
Add anything a second presentation could use there instead of copying it.

## Development

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces)
managed with [Melos](https://melos.invertase.dev):

```sh
dart pub global activate melos
melos bootstrap
melos analyze
melos test
```

## Adding a presentation

1. Create a Flutter project in a new directory, with a `web` platform.
2. Add `resolution: workspace` and a `common: any` dependency to its
   `pubspec.yaml`, and the directory to the `workspace` list of the root
   `pubspec.yaml`.
3. Run the slides through `PresentationApp` from `package:common`.
4. Add a card for it to `index.html` and a row to the table above.

`.github/workflows/deploy_pages.yml` checks the formatting, analyzes and tests
every package, and builds every presentation with `melos run build_web` on
every pull request. On push to `main` it deploys them, each under
`/<directory>/` next to the landing page.
