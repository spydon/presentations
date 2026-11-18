// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/common.dart';
import 'package:supabase_flutter_passkeys/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The number of people with a passkey in the project, updated live, with a
/// burst of confetti above the number whenever someone creates their first one.
class PasskeyCounter extends StatefulWidget {
  const PasskeyCounter({super.key});

  @override
  State<PasskeyCounter> createState() => _PasskeyCounterState();
}

class _PasskeyCounterState extends State<PasskeyCounter> {
  final _stats = Supabase.instance.client
      .table(PasskeyStats.table)
      .stream(primaryKey: [PasskeyStats.id]);
  final _confetti = GlobalKey<ConfettiBurstState>();
  int? _count;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stats,
      builder: (context, snapshot) {
        final rows = snapshot.data;
        final count = rows == null || rows.isEmpty
            ? null
            : rows.first.passkeyUsers;
        if (count != null && count != _count) {
          final previous = _count;
          _count = count;
          if (previous != null && count > previous) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _confetti.currentState?.burst(),
            );
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConfettiBurst(
              key: _confetti,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                ),
                child: Text(
                  count?.toString() ?? '-',
                  key: ValueKey(count),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Brand.green,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                count == 1
                    ? 'person has created a passkey'
                    : 'people have created a passkey',
                style: const TextStyle(fontSize: 30, color: Brand.mutedText),
              ),
            ),
          ],
        );
      },
    );
  }
}
