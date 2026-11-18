# Presentations

Slide decks built with [flutter_deck](https://pub.dev/packages/flutter_deck),
one Flutter project per directory, published at
<https://spydon.github.io/presentations/>.

| Directory                                    | Talk                              | Length    |
| -------------------------------------------- | --------------------------------- | --------- |
| [`supabase_flutter_v3`](supabase_flutter_v3) | What's new in supabase_flutter v3 | 2 minutes |

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
2. Add `resolution: workspace` to its `pubspec.yaml`, and the directory to the
   `workspace` list of the root `pubspec.yaml`.
3. Add a card for it to `index.html` and a row to the table above.

`.github/workflows/deploy_pages.yml` analyzes, tests and builds every directory
that has a `pubspec.yaml` on every pull request, and deploys them on push to
`main`, each under `/presentations/<directory>/` next to the landing page.
