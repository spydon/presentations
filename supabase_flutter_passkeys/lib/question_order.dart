import 'package:supabase_flutter_passkeys/supabase_schema.g.dart';

/// Most upvoted first. Ties go to the newest question, so a fresh question is
/// not buried below older ones that nobody voted for either.
List<QuestionsRow> byVotes(Iterable<QuestionsRow> questions) =>
    questions.toList()..sort((a, b) {
      final votes = b.voteCount.compareTo(a.voteCount);
      return votes != 0 ? votes : b.createdAt.compareTo(a.createdAt);
    });
