# Presentations

Slide decks built with [flutter_deck](https://pub.dev/packages/flutter_deck),
one Flutter project per directory, published at
<https://spydon.github.io/presentations/>.

| Directory                                    | Talk                              | Length    |
| -------------------------------------------- | --------------------------------- | --------- |
| [`supabase_flutter_v3`](supabase_flutter_v3) | What's new in supabase_flutter v3 | 2 minutes |

## Adding a presentation

1. Create a Flutter project in a new directory, with a `web` platform.
2. Add a card for it to `index.html` and a row to the table above.

`.github/workflows/deploy_pages.yml` analyzes, tests and builds every directory
that has a `pubspec.yaml` on every pull request, and deploys them on push to
`main`, each under `/presentations/<directory>/` next to the landing page.
