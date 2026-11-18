# What's new in supabase-py v3

A two minute [flutter_deck](https://pub.dev/packages/flutter_deck)
presentation about the [supabase-py](https://github.com/supabase/supabase-py)
v3 alpha. It covers the type safety: the schema generated with
`supabase gen types --lang python`, typed tables and typed database function
calls, with before and after comparisons against v2.

## Running

```sh
flutter run -d chrome
```

Use the arrow keys to move between slides and steps. Speaker notes are in the
presenter view, opened from the deck menu.

## Testing

```sh
flutter analyze
flutter test
```

The tests render every slide at 1920x1080 and fail on overflow.
