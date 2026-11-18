import 'dart:convert';

// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter_v3/brand.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

/// A SQL listing styled like [FlutterDeckCodeHighlight].
///
/// The `sql` grammar bundled with `syntax_highlight` relies on the `(?i)`
/// inline flag, which Dart regular expressions do not support, so it leaves
/// almost everything uncolored. This widget uses [_postgresGrammar] instead.
class SqlCode extends StatelessWidget {
  const SqlCode({
    required this.code,
    this.fileName,
    this.fontSize = 28,
    super.key,
  });

  final String code;
  final String? fileName;
  final double fontSize;

  static final Future<Highlighter> _highlighter = () async {
    Highlighter.addLanguage(_language, jsonEncode(_postgresGrammar));
    return Highlighter(
      language: _language,
      theme: await HighlighterTheme.loadDarkTheme(),
    );
  }();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      height: 1.4,
      color: Brand.text,
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fileName case final fileName?) ...[
              Text(fileName, style: style),
              const SizedBox(height: 8),
            ],
            FutureBuilder(
              future: _highlighter,
              builder: (context, snapshot) => Text.rich(
                snapshot.data?.highlight(code) ?? TextSpan(text: code),
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _language = 'postgres';

const _keywords = [
  'add',
  'alter',
  'always',
  'as',
  'by',
  'cascade',
  'check',
  'constraint',
  'create',
  'default',
  'delete',
  'drop',
  'enable',
  'exists',
  'foreign',
  'from',
  'generated',
  'identity',
  'if',
  'index',
  'insert',
  'into',
  'key',
  'level',
  'not',
  'on',
  'policy',
  'primary',
  'references',
  'row',
  'security',
  'select',
  'table',
  'unique',
  'update',
  'using',
  'values',
  'where',
  'with',
];

const _types = [
  'bigint',
  'boolean',
  'bytea',
  'date',
  'double precision',
  'int',
  'integer',
  'json',
  'jsonb',
  'numeric',
  'real',
  'smallint',
  'text',
  'timestamp',
  'timestamptz',
  'uuid',
  'varchar',
];

String _words(List<String> words) =>
    '\\b(${[...words, ...words.map((word) => word.toUpperCase())].join('|')})\\b';

final _postgresGrammar = {
  'name': 'Postgres',
  'scopeName': 'source.sql.postgres',
  'patterns': [
    {'name': 'comment.line.double-dash.sql', 'match': r'--.*$'},
    {'name': 'comment.block.sql', 'begin': r'/\*', 'end': r'\*/'},
    {'name': 'string.quoted.single.sql', 'begin': "'", 'end': "'"},
    {'name': 'constant.numeric.sql', 'match': r'\b\d+(\.\d+)?\b'},
    {
      'name': 'constant.language.sql',
      'match': _words(['null', 'true', 'false']),
    },
    {'name': 'support.type.sql', 'match': _words(_types)},
    {'name': 'keyword.other.sql', 'match': _words(_keywords)},
    {'name': 'support.function.sql', 'match': r'\b[A-Za-z_]\w*(?=\()'},
  ],
};
