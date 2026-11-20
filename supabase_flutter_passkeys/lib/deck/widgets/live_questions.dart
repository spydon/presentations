import 'package:material_ui/material_ui.dart';
import 'package:common/common.dart';
import 'package:supabase_flutter_passkeys/question_order.dart';
import 'package:supabase_flutter_passkeys/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The audience's questions, most upvoted first, updated live over realtime.
/// Cards slide to their new place when the votes change the order.
class LiveQuestions extends StatefulWidget {
  const LiveQuestions({super.key});

  @override
  State<LiveQuestions> createState() => _LiveQuestionsState();
}

class _LiveQuestionsState extends State<LiveQuestions> {
  final _questions = Supabase.instance.client
      .table(Questions.table)
      .stream(primaryKey: [Questions.id])
      .order(Questions.createdAt.desc());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _questions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Placeholder(
            icon: Icons.cloud_off,
            text: 'Could not load questions:\n${snapshot.error}',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final questions = byVotes(snapshot.requireData);
        if (questions.isEmpty) {
          return const _Placeholder(
            icon: Icons.forum_outlined,
            text: 'Scan the code and ask the first question!',
          );
        }
        final newestId = questions
            .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
            .id;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${questions.length} question${questions.length == 1 ? '' : 's'}'
              ' · most upvoted first',
              style: const TextStyle(fontSize: 28, color: Brand.mutedText),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedReorderColumn(
                  children: [
                    for (final question in questions)
                      PopIn(
                        key: ValueKey(question.id),
                        child: _QuestionCard(
                          question: question,
                          isNewest: question.id == newestId,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.isNewest});

  final QuestionsRow question;
  final bool isNewest;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNewest ? Brand.green : Brand.surfaceHigh,
          width: isNewest ? 3 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VoteBadge(count: question.voteCount),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.content,
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.3,
                    color: Brand.text,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.key_rounded, size: 26, color: Brand.green),
                    const SizedBox(width: 8),
                    Text(
                      '${question.authorName} · ${_timeOf(question.createdAt)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Brand.mutedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _timeOf(DateTime time) {
    final local = time.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

/// Scales and fades a question in the first time it is built, so new
/// questions pop up on the slide.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 96, color: Brand.mutedText),
          const SizedBox(height: 24),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, color: Brand.mutedText),
          ),
        ],
      ),
    );
  }
}

/// The upvote count, bumping briefly whenever it changes.
class _VoteBadge extends StatelessWidget {
  const _VoteBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Icon(
            Icons.arrow_upward_rounded,
            size: 36,
            color: count > 0 ? Brand.green : Brand.mutedText,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$count',
              key: ValueKey(count),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: count > 0 ? Brand.green : Brand.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
