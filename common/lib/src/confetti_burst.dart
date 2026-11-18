import 'dart:math';

// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/src/brand.dart';

/// Shoots confetti upwards from the top of [child] when [burst] is called.
/// The confetti only covers the area above the child.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    required this.child,
    this.height = 260,
    this.particleCount = 60,
    super.key,
  });

  final Widget child;

  /// How far above the child the confetti can fly.
  final double height;
  final int particleCount;

  @override
  State<ConfettiBurst> createState() => ConfettiBurstState();
}

class ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Brand.green,
    Color(0xFFFFC857),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFA78BFA),
    Colors.white,
  ];

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  final _random = Random();
  var _particles = <_Particle>[];

  void burst() {
    _particles = [
      for (var i = 0; i < widget.particleCount; i++)
        _Particle(
          // Mostly upwards, spread up to 40 degrees to each side.
          angle: -pi / 2 + (_random.nextDouble() - 0.5) * pi * 0.45,
          speed: 0.55 + _random.nextDouble() * 0.45,
          spin: (_random.nextDouble() - 0.5) * 16,
          size: 6 + _random.nextDouble() * 8,
          color: _colors[_random.nextInt(_colors.length)],
          startX: (_random.nextDouble() - 0.5) * 0.6,
        ),
    ];
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          left: -widget.height / 2,
          right: -widget.height / 2,
          // The confetti area ends where the child starts.
          top: -widget.height,
          height: widget.height,
          child: IgnorePointer(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.isAnimating ? _controller.value : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.color,
    required this.startX,
  });

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final Color color;

  /// Horizontal start offset as a fraction of the emitter width.
  final double startX;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    // The emitter sits at the bottom center, where the number's top is.
    final origin = Offset(size.width / 2, size.height);
    final t = progress;
    final opacity = (1 - t * t).clamp(0.0, 1.0);
    for (final particle in particles) {
      // A ballistic path: launched up, pulled back down by gravity.
      final distance = particle.speed * size.height * 1.9;
      final dx = cos(particle.angle) * distance * t;
      final dy = sin(particle.angle) * distance * t + size.height * 1.4 * t * t;
      final position =
          origin + Offset(particle.startX * size.width * 0.3 + dx, dy);
      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(particle.spin * t);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.5,
        ),
        Paint()..color = particle.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      !identical(oldDelegate.particles, particles);
}
