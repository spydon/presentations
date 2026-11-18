# What's new in supabase_flutter v3

A two minute [flutter_deck](https://pub.dev/packages/flutter_deck)
presentation about [supabase_flutter](https://pub.dev/packages/supabase_flutter)
v3. It covers:

- **Built for agents**: the package skills, installed with
  `dart run skills@ get -p <package>`, that teach coding agents how to migrate
  to v3, generate the typed schema with the Supabase CLI and write tests.
- **Type safety**: the generated schema, the typed `table()` API and typed
  database function calls, with before and after comparisons against v2, and
  the sealed auth events.
- **Passkeys**: signing in without a password.

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
