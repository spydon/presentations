import 'package:common/common.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_passkeys/supabase_schema.g.dart';

/// The names of everyone who has created a passkey, scrolling past in an
/// endless loop, updated live as people join.
class PasskeyCreatorsTicker extends StatefulWidget {
  const PasskeyCreatorsTicker({super.key});

  @override
  State<PasskeyCreatorsTicker> createState() => _PasskeyCreatorsTickerState();
}

class _PasskeyCreatorsTickerState extends State<PasskeyCreatorsTicker>
    with SingleTickerProviderStateMixin {
  /// How fast the names scroll past, in logical pixels per second.
  static const _speed = 90.0;

  final _creators = Supabase.instance.client
      .table(PasskeyCreators.table)
      .stream(primaryKey: [PasskeyCreators.userId])
      .order(PasskeyCreators.createdAt.asc());
  final _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_scroll)..start();
  }

  void _scroll(Duration elapsed) {
    final seconds = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.offset + _speed * seconds);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: StreamBuilder(
        stream: _creators,
        builder: (context, snapshot) {
          final names = [
            for (final creator in snapshot.data ?? const <PasskeyCreatorsRow>[])
              creator.displayName,
          ];
          if (names.isEmpty) {
            return const Center(
              child: Text(
                'Create the first passkey and see your name here!',
                style: TextStyle(fontSize: 28, color: Brand.mutedText),
              ),
            );
          }
          // Fades the names in and out at the edges.
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0, 0.08, 0.92, 1],
            ).createShader(bounds),
            // An endless list that repeats the names, which the ticker
            // scrolls through.
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  _Name(name: names[index % names.length]),
            ),
          );
        },
      ),
    );
  }
}

class _Name extends StatelessWidget {
  const _Name({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.key_rounded, size: 30, color: Brand.green),
        const SizedBox(width: 14),
        Text(
          name,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
