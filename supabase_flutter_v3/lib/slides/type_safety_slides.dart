import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class TypeSafetySlide extends FlutterDeckSlideWidget {
  const TypeSafetySlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/type-safety',
          title: 'Typed from the database up',
          header: FlutterDeckHeaderConfiguration(
            title: 'Typed from the database up',
          ),
          speakerNotes:
              '- The second big theme of v3 is type safety.\n'
              '- The Supabase CLI reads your schema and generates Dart for it, the typegen skill tells the agent how.\n'
              '- One row type, one insert type, one update type and one table class per table.\n'
              '- Run it again after every migration.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Terminal(
            fontSize: 30,
            commands: [
              'supabase gen types --lang dart > lib/supabase_schema.g.dart',
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: SqlCode(
                  fileName: 'migration.sql',
                  fontSize: 26,
                  code: '''
create table books (
  id bigint primary key
    generated always as identity,
  author_id bigint not null,
  title text not null,
  price numeric,
  created_at timestamptz
    not null default now()
);''',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 80,
                  color: Brand.green,
                ),
              ),
              Expanded(
                child: SlideCode(
                  fileName: 'supabase_schema.g.dart',
                  fontSize: 26,
                  code: '''
// What you read
extension type BooksRow

// What you insert
extension type BooksInsert

// What you update
extension type BooksUpdate

// Table, columns and relations
class Books''',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReadingSlide extends FlutterDeckSlideWidget {
  const ReadingSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/reading',
          title: 'Reading rows',
          steps: 2,
          header: FlutterDeckHeaderConfiguration(title: 'Reading rows'),
          speakerNotes:
              '- v2: the table, the columns and the operator are all strings, and the row is a Map<String, dynamic>.\n'
              '- A typo, a renamed column or a wrong cast only shows up when the query runs.\n'
              '- v3: table() takes the generated table, filters are methods on typed column constants, and rows come back as BooksRow.\n'
              '- Books.price.lt only accepts a number, and title is a String, no cast.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Before: v2',
        isAfter: false,
        code: '''
final books = await supabase
    .from('books')
    .select()
    .lt('price', 10)
    .order('created_at', ascending: false);

final title = books.first['title'] as String;''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'After: v3',
          isAfter: true,
          visible: step >= 2,
          code: '''
final books = await supabase
    .table(Books.table)
    .select()
    .where(Books.price.lt(10))
    .order(Books.createdAt.desc());

final String title = books.first.title;''',
        ),
      ),
    );
  }
}

class WritingSlide extends FlutterDeckSlideWidget {
  const WritingSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/writing',
          title: 'Writing rows',
          steps: 2,
          header: FlutterDeckHeaderConfiguration(title: 'Writing rows'),
          speakerNotes:
              '- v2: you insert a map, so a misspelled column compiles fine and fails at runtime, in front of a user.\n'
              '- v3: BooksInsert has a required parameter for every required column, and none for generated ones like id.\n'
              '- The typo and the wrong value type are now compile errors.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Before: v2',
        isAfter: false,
        code: '''
await supabase.from('books').insert({
  'author_id': 2,
  'titel': 'Dune',
});
// Compiles, then fails at runtime:
// Could not find the 'titel' column''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'After: v3',
          isAfter: true,
          visible: step >= 2,
          code: '''
await supabase
    .table(Books.table)
    .insert(
      BooksInsert(authorId: 2, title: 'Dune'),
    );

// Does not compile:
BooksInsert(authorId: 2, titel: 'Dune');
Books.price.lt('ten');''',
        ),
      ),
    );
  }
}

class FunctionsSlide extends FlutterDeckSlideWidget {
  const FunctionsSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/functions',
          title: 'Calling database functions',
          steps: 2,
          header: FlutterDeckHeaderConfiguration(
            title: 'Calling database functions',
          ),
          speakerNotes:
              '- Database functions get the same treatment as tables.\n'
              '- v2: the function name and its parameters are strings in a map, and the result is dynamic.\n'
              '- v3: the generator adds a method on supabase.rpc for every function, with typed parameters and a typed result.\n'
              '- A function returning rows of a table resolves to that row type, here BooksRow.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Before: v2',
        isAfter: false,
        code: '''
final books = await supabase.rpc(
  'search_books',
  params: {'query': 'dart'},
);

final title = books.first['title'] as String;''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'After: v3',
          isAfter: true,
          visible: step >= 2,
          code: '''
final books = await supabase.rpc
    .searchBooks(query: 'dart');

final String title = books.first.title;

// Does not compile:
supabase.rpc.searchBooks(qeury: 'dart');
supabase.rpc.searchBooks(query: 42);''',
        ),
      ),
    );
  }
}

class WhyTypesSlide extends FlutterDeckSlideWidget {
  const WhyTypesSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/why-types',
          title: 'Why this matters',
          steps: 4,
          header: FlutterDeckHeaderConfiguration(title: 'Why this matters'),
          speakerNotes:
              '- Bugs move from production to the compiler.\n'
              '- A migration renames a column: regenerate, and the analyzer points at every query to fix.\n'
              '- Autocomplete on every table, column and relation.\n'
              '- And it closes the loop with the first half: an agent gets the same instant feedback from the analyzer and fixes its own mistakes.\n'
              '- No runtime cost: rows are extension types over the JSON. And from() still works, so migrate one table at a time.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      splitRatio: const SplitSlideRatio(left: 3, right: 2),
      leftBuilder: (context) => Center(
        child: FlutterDeckBulletList(
          useSteps: true,
          items: const [
            'Typos and wrong types are compile errors, not production bugs',
            'Change the schema, regenerate, and the analyzer finds every query to fix',
            'Autocomplete for every table, column and relation',
            'Agents get the same instant feedback, and fix their own mistakes',
          ],
        ),
      ),
      rightBuilder: (context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InfoTile(
            icon: Icons.bolt,
            title: 'No runtime cost',
            text:
                'Rows, inserts and updates are extension types over the JSON.',
          ),
          SizedBox(height: 32),
          InfoTile(
            icon: Icons.swap_horiz,
            title: 'Migrate gradually',
            text: 'from() keeps working, so move one table at a time.',
          ),
        ],
      ),
    );
  }
}
