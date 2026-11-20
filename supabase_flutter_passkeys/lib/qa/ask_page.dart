import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter_passkeys/qa/passkey_auth.dart';
import 'package:common/common.dart';
import 'package:supabase_flutter_passkeys/question_order.dart';
import 'package:supabase_flutter_passkeys/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lets a signed in member of the audience post questions and remove their
/// own.
class AskPage extends StatefulWidget {
  const AskPage({required this.user, super.key});

  final User user;

  @override
  State<AskPage> createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  final _supabase = Supabase.instance.client;
  final _controller = TextEditingController();
  late final Stream<List<QuestionsRow>> _questions = _supabase
      .table(Questions.table)
      .stream(primaryKey: [Questions.id])
      .order(Questions.createdAt.desc());
  late final Stream<List<QuestionVotesRow>> _myVotes = _supabase
      .table(QuestionVotes.table)
      .stream(primaryKey: [QuestionVotes.questionId, QuestionVotes.userId])
      .filter(QuestionVotes.userId.eq(widget.user.id));
  bool _sending = false;

  /// Questions with a vote change on the way, to avoid double taps.
  final _pendingVotes = <int>{};

  String get _name => displayNameOf(widget.user);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _supabase
          .table(Questions.table)
          .insert(QuestionsInsert(authorName: _name, content: content));
      _controller.clear();
      _showMessage('Sent! Look at the big screen.');
    } on SupabaseException catch (error) {
      _showMessage('Could not send the question: ${error.message}');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(QuestionsRow question) async {
    try {
      await _supabase
          .table(Questions.table)
          .delete()
          .where(Questions.id.eq(question.id));
    } on SupabaseException catch (error) {
      _showMessage('Could not delete the question: ${error.message}');
    }
  }

  Future<void> _toggleVote(QuestionsRow question, {required bool voted}) async {
    if (!_pendingVotes.add(question.id)) return;
    setState(() {});
    try {
      if (voted) {
        await _supabase
            .table(QuestionVotes.table)
            .delete()
            .where(
              QuestionVotes.questionId.eq(question.id) &
                  QuestionVotes.userId.eq(widget.user.id),
            );
      } else {
        await _supabase
            .table(QuestionVotes.table)
            .insert(QuestionVotesInsert(questionId: question.id));
      }
    } on SupabaseException catch (error) {
      _showMessage('Could not update your vote: ${error.message}');
    } finally {
      _pendingVotes.remove(question.id);
      if (mounted) setState(() {});
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi $_name'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => _supabase.auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Brand.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: Brand.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Signed in with a passkey. No password was involved.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  enabled: !_sending,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 280,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'What would you like to know about passkeys?',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Ask'),
                ),
                const SizedBox(height: 32),
                Text('Questions', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text(
                  'Upvote the ones you want answered.',
                  style: TextStyle(color: Brand.mutedText),
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: _myVotes,
                  builder: (context, votesSnapshot) {
                    final votedIds = {
                      for (final vote
                          in votesSnapshot.data ?? const <QuestionVotesRow>[])
                        vote.questionId,
                    };
                    return StreamBuilder(
                      stream: _questions,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Could not load the questions: ${snapshot.error}',
                            style: const TextStyle(color: Brand.mutedText),
                          );
                        }
                        final questions = byVotes(snapshot.data ?? const []);
                        if (questions.isEmpty) {
                          return const Text(
                            'Nothing yet, be the first!',
                            style: TextStyle(color: Brand.mutedText),
                          );
                        }
                        return AnimatedReorderColumn(
                          // The cards bring their own margin.
                          spacing: 0,
                          children: [
                            for (final question in questions)
                              PopIn(
                                key: ValueKey(question.id),
                                child: _QuestionTile(
                                  question: question,
                                  isOwn: question.userId == widget.user.id,
                                  voted: votedIds.contains(question.id),
                                  busy: _pendingVotes.contains(question.id),
                                  onToggleVote: () => _toggleVote(
                                    question,
                                    voted: votedIds.contains(question.id),
                                  ),
                                  onDelete: () => _delete(question),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.question,
    required this.isOwn,
    required this.voted,
    required this.busy,
    required this.onToggleVote,
    required this.onDelete,
  });

  final QuestionsRow question;
  final bool isOwn;
  final bool voted;
  final bool busy;
  final VoidCallback onToggleVote;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = voted ? Brand.green : Brand.mutedText;
    return Card(
      color: Brand.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: isOwn
                        ? 'You cannot upvote your own question'
                        : voted
                        ? 'Remove upvote'
                        : 'Upvote',
                    onPressed: isOwn || busy ? null : onToggleVote,
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: isOwn ? Brand.surfaceHigh : color,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '${question.voteCount}',
                      key: ValueKey(question.voteCount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question.content),
                  const SizedBox(height: 4),
                  Text(
                    isOwn ? 'You' : question.authorName,
                    style: const TextStyle(
                      color: Brand.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isOwn)
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
