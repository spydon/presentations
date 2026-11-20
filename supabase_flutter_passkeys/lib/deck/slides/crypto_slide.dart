import 'dart:async';
import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:material_ui/material_ui.dart';

class AsymmetricCryptographySlide extends FlutterDeckSlideWidget {
  const AsymmetricCryptographySlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/asymmetric-cryptography',
          title: 'Asymmetric cryptography',
          steps: 4,
          header: FlutterDeckHeaderConfiguration(
            title: 'Asymmetric cryptography',
          ),
          speakerNotes:
              '- Two keys, generated together and mathematically linked, but you cannot derive one from the other.\n'
              '- The private key signs: only its holder can produce a valid signature for a message.\n'
              '- The public key verifies: anyone can check that a signature came from the private key.\n'
              '- So the server can store the public key in the open. It can check you, but never impersonate you.\n'
              '- Passkeys use ECDSA P-256 (ES256) by default, the same idea with elliptic curves.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Reveal(
              visible: step >= 1,
              child: _KeyPairRow(step: step),
            ),
            _SignAndVerifyRow(step: step),
            _Reveal(
              visible: step >= 4,
              child: const Pill(
                icon: Icons.shield_outlined,
                text:
                    'The public key can check a signature, but never forge one',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The private and the public key, joined by the link between them. The key
/// in use is highlighted: both while they are introduced, the private key
/// while signing and the public key from verifying on.
class _KeyPairRow extends StatelessWidget {
  const _KeyPairRow({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    // As tall as the taller card, so that both cards and the link line up.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KeyCard(
              icon: Icons.key_rounded,
              badge: Icons.lock_rounded,
              title: 'Private key',
              text: 'Signs. Never leaves your device.',
              isPrivate: true,
              highlighted: step <= 2,
            ),
          ),
          const SizedBox(width: 280, child: _KeyLink()),
          Expanded(
            child: _KeyCard(
              icon: Icons.key_rounded,
              badge: Icons.public_rounded,
              title: 'Public key',
              text: 'Verifies. Safe to give to anyone.',
              isPrivate: false,
              highlighted: step != 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyCard extends StatelessWidget {
  const _KeyCard({
    required this.icon,
    required this.badge,
    required this.title,
    required this.text,
    required this.isPrivate,
    required this.highlighted,
  });

  final IconData icon;
  final IconData badge;
  final String title;
  final String text;
  final bool isPrivate;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: Brand.card(highlighted: highlighted),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Brand.green.withValues(alpha: 0.12),
                ),
                child: Transform.rotate(
                  angle: isPrivate ? -math.pi / 4 : math.pi * 3 / 4,
                  child: Icon(icon, size: 72, color: Brand.green),
                ),
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Brand.surfaceHigh,
                    border: Border.all(color: Brand.surface, width: 4),
                  ),
                  child: Icon(badge, size: 32, color: Brand.green),
                ),
              ),
            ],
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Brand.mutedText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A dashed line between the two keys with a link in the middle: generated
/// together, but one cannot be worked out from the other.
class _KeyLink extends StatelessWidget {
  const _KeyLink();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: _DashedLinePainter()),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.background,
                border: Border.all(color: Brand.mutedText, width: 2),
              ),
              child: const Icon(
                Icons.link_rounded,
                size: 48,
                color: Brand.text,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'one key pair',
              style: TextStyle(fontSize: 26, color: Brand.mutedText),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Brand.mutedText
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const dash = 12.0;
    const gap = 10.0;
    // Lined up with the middle of the link icon, which sits above the label.
    final y = size.height / 2 - 20;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

/// The challenge, signed with the private key and verified with the public
/// key, revealed over steps 2 and 3.
class _SignAndVerifyRow extends StatelessWidget {
  const _SignAndVerifyRow({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Row(
        children: [
          _Reveal(
            visible: step >= 2,
            child: const _DataCard(
              icon: Icons.description_outlined,
              title: 'Challenge',
              data: '7f3a 91c2 e04b\nd5a8 2c61 …',
            ),
          ),
          Expanded(
            child: _FlowArrow(
              visible: step >= 2,
              icon: Icons.key_rounded,
              label: 'sign with\nprivate key',
              color: Brand.green,
            ),
          ),
          _Reveal(
            visible: step >= 2,
            delay: const Duration(milliseconds: 500),
            child: _DataCard(
              icon: Icons.draw_outlined,
              title: 'Signature',
              data: '3045 0221 00c8\n9be1 4f07 …',
              // Made by signing, and checked when verifying.
              highlighted: step == 2 || step == 3,
            ),
          ),
          Expanded(
            child: _FlowArrow(
              visible: step >= 3,
              icon: Icons.key_rounded,
              label: 'verify with\npublic key',
              color: Brand.green,
            ),
          ),
          SizedBox(
            width: 300,
            child: step >= 3
                ? const _Delayed(
                    delay: Duration(milliseconds: 500),
                    child: PopIn(child: _VerifiedBadge()),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.icon,
    required this.title,
    required this.data,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String data;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: Brand.card(highlighted: highlighted),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 44, color: Brand.green),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Brand.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data,
              style: TextStyle(
                fontFamily: Brand.monospaceFontFamily,
                fontSize: 26,
                height: 1.4,
                color: Brand.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An arrow that draws itself from left to right when [visible] turns true,
/// with the key used for the step above it.
class _FlowArrow extends StatelessWidget {
  const _FlowArrow({
    required this.visible,
    required this.icon,
    required this.label,
    required this.color,
  });

  final bool visible;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: visible ? 1 : 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => Opacity(
        opacity: progress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: -math.pi / 4,
                child: Icon(icon, size: 44, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, color: color, height: 1.2),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 24,
                width: double.infinity,
                child: CustomPaint(
                  painter: _ArrowPainter(progress: progress, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    final end = size.width * progress;
    canvas.drawLine(Offset(0, y), Offset(end, y), paint);
    const head = 14.0;
    canvas.drawPath(
      Path()
        ..moveTo(end - head, y - head)
        ..lineTo(end, y)
        ..lineTo(end - head, y + head),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Brand.green,
            boxShadow: [
              BoxShadow(
                color: Brand.green.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 100,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "It's really you",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Fades and slides [child] up into place when [visible] turns true.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.visible,
    required this.child,
    this.delay = Duration.zero,
  });

  final bool visible;
  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Delayed(
      delay: visible ? delay : Duration.zero,
      builder: (ready) => AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        offset: visible && ready ? Offset.zero : const Offset(0, 0.15),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: visible && ready ? 1 : 0,
          child: child,
        ),
      ),
    );
  }
}

/// Builds [child], or calls [builder], once [delay] has passed since it was
/// first built.
class _Delayed extends StatefulWidget {
  const _Delayed({required this.delay, this.child, this.builder})
    : assert(child != null || builder != null);

  final Duration delay;
  final Widget? child;
  final Widget Function(bool ready)? builder;

  @override
  State<_Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<_Delayed> {
  bool _ready = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(_Delayed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay) {
      _schedule();
    }
  }

  void _schedule() {
    _timer?.cancel();
    _ready = widget.delay == Duration.zero;
    if (!_ready) {
      _timer = Timer(widget.delay, () => setState(() => _ready = true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder case final builder?) {
      return builder(_ready);
    }
    return _ready ? widget.child! : const SizedBox.shrink();
  }
}
