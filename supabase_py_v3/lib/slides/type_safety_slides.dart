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
              '- The big theme of v3 is type safety.\n'
              '- The Supabase CLI reads your schema and generates Python for it.\n'
              '- One table class with typed columns, a pydantic model for the rows, and TypedDicts for inserts and updates.\n'
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
            commands: ['supabase gen types --lang python > supabase_schema.py'],
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
  id bigint primary key,
  author_id bigint not null,
  title text not null,
  price numeric,
  created_at timestamptz not null
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
                  fileName: 'supabase_schema.py',
                  language: 'python',
                  fontSize: 26,
                  code: '''
# Table, columns and relations
class Books

# What you read
class BooksRow(BaseModel)

# What you insert
class BooksInsert(TypedDict)

# What you update
class BooksUpdate(TypedDict)''',
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
              '- v2: the table, the columns and the operator are all strings, and every row is a dict.\n'
              '- A typo or a renamed column only shows up when the query runs, as a KeyError or an error from the server.\n'
              '- v3: table() takes the generated table, filters are methods on typed columns, and execute() returns a list of BooksRow.\n'
              '- Books.price.lt only accepts a number, and title is a str your editor knows about.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Before: v2',
        isAfter: false,
        language: 'python',
        code: '''
response = (
    supabase.table("books")
    .select("*")
    .lt("price", 10)
    .order("created_at", desc=True)
    .execute()
)

title = response.data[0]["title"]''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'After: v3',
          isAfter: true,
          language: 'python',
          visible: step >= 2,
          code: '''
books = (
    supabase.table(Books.table)
    .select()
    .where(Books.price.lt(10))
    .order(Books.created_at.desc())
    .execute()
)

title: str = books[0].title''',
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
              '- v2: you insert a dict, so a misspelled column passes every check and fails at runtime, in production.\n'
              '- v3: the insert is a BooksInsert TypedDict, with the required columns required and generated ones like id left out.\n'
              '- The typo and the wrong value type are now errors in your type checker and your editor.\n'
              '- And the payload is validated with pydantic before anything is sent.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Before: v2',
        isAfter: false,
        language: 'python',
        code: '''
supabase.table("books").insert({
    "author_id": 2,
    "titel": "Dune",
}).execute()
# Runs, then fails on the server:
# Could not find the 'titel' column''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'After: v3',
          isAfter: true,
          language: 'python',
          visible: step >= 2,
          code: '''
supabase.table(Books.table).insert({
    "author_id": 2,
    "title": "Dune",
}).execute()

# Type errors:
supabase.table(Books.table).insert({"titel": "Dune"})
Books.price.lt("ten")''',
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
              '- v2: the function name and its parameters are strings in a dict, and the result is untyped JSON.\n'
              '- v3: the generator adds a function for every database function, with typed parameters and a typed result.\n'
              '- A function returning rows of a table returns that row model, here BooksRow, and can still be filtered and ordered.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Before: v2',
        isAfter: false,
        language: 'python',
        code: '''
response = supabase.rpc(
    "search_books",
    {"query": "python"},
).execute()

title = response.data[0]["title"]''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'After: v3',
          isAfter: true,
          language: 'python',
          visible: step >= 2,
          code: '''
books = supabase.rpc(
    search_books(query="python"),
).execute()

title: str = books[0].title

# Type errors:
search_books(qeury="python")
search_books(query=42)''',
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
              '- Bugs move from production to your type checker.\n'
              '- A migration renames a column: regenerate, and the type checker points at every query to fix.\n'
              '- Autocomplete on every table, column and relation.\n'
              '- Coding agents get the same instant feedback from the type checker and fix their own mistakes.\n'
              '- Client and AsyncClient take the same generated types. And string table names still work, so migrate one table at a time.',
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
            'Typos and wrong types are type errors, not production bugs',
            'Change the schema, regenerate, and the type checker finds every query to fix',
            'Autocomplete for every table, column and relation',
            'Agents get the same instant feedback, and fix their own mistakes',
          ],
        ),
      ),
      rightBuilder: (context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InfoTile(
            icon: Icons.sync_alt,
            title: 'Sync and async',
            text: 'Client and AsyncClient take the same generated types.',
          ),
          SizedBox(height: 32),
          InfoTile(
            icon: Icons.stairs_outlined,
            title: 'Migrate gradually',
            text:
                'String table names keep working, so move one table at a time.',
          ),
        ],
      ),
    );
  }
}
