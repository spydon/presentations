import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:common/src/brand.dart';

/// A role of a speaker, such as their job, with a leading icon or logo.
class SpeakerRole {
  const SpeakerRole({required this.leading, required this.text});

  final Widget leading;
  final String text;
}

/// A link or handle of a speaker, such as a social media handle.
class SpeakerLink {
  const SpeakerLink({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// A speaker introduction: a round photo in a glowing ring next to the name,
/// roles and links, which animate in one after another.
class SpeakerCard extends StatelessWidget {
  const SpeakerCard({
    required this.name,
    required this.photo,
    this.greeting = "Hi, I'm",
    this.roles = const [],
    this.links = const [],
    super.key,
  });

  /// Lukas Klingsbo's photo, from `package:common`.
  static const lukasPhoto = AssetImage(
    'assets/images/lukas_klingsbo.jpg',
    package: 'common',
  );

  final String name;
  final ImageProvider photo;
  final String greeting;
  final List<SpeakerRole> roles;
  final List<SpeakerLink> links;

  @override
  Widget build(BuildContext context) {
    // Everything after the photo enters in this order.
    var order = 0;
    Widget next(Widget child) => _Entrance(order: order++, child: child);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Entrance(order: 0, slide: false, child: _Photo(photo: photo)),
        const SizedBox(width: 112),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              next(
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 44, color: Brand.mutedText),
                ),
              ),
              next(
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 104,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              next(
                Container(
                  width: 160,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [Brand.green, Brand.green.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 44),
              for (final role in roles)
                next(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _RoleRow(role: role),
                  ),
                ),
              if (links.isNotEmpty) ...[
                const SizedBox(height: 28),
                next(
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [for (final link in links) _LinkChip(link: link)],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.photo});

  final ImageProvider photo;

  static const size = 520.0;

  /// The space around the photo for the ring, the glow and the ripples.
  static const margin = 60.0;

  /// The gap between the ring and the photo.
  static const gap = 14.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size + margin * 2,
      child: CustomPaint(
        painter: const _RingPainter(radius: size / 2),
        child: Center(
          child: SizedBox.square(
            dimension: size - (_RingPainter.width + gap) * 2,
            // The photo is only scaled once, with high quality filtering,
            // since a 720 pixel photo has little detail to spare.
            child: ClipOval(
              child: Image(
                image: photo,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The glow, the gradient ring and the faint ripples around the photo.
///
/// Each is a single anti-aliased stroke on the canvas, rather than filled
/// circles stacked on top of each other, whose overlapping edges leave a
/// jagged fringe.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.radius});

  final double radius;

  static const width = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringRadius = radius - width / 2;

    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 3
        ..color = Brand.green.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32),
    );

    for (final (index, extra) in const [60.0, 32.0].indexed) {
      canvas.drawCircle(
        center,
        radius + extra,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..isAntiAlias = true
          ..color = Brand.green.withValues(alpha: 0.1 + 0.08 * index),
      );
    }

    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..isAntiAlias = true
        ..shader = const SweepGradient(
          transform: GradientRotation(-math.pi / 2),
          colors: [
            Brand.green,
            Color(0xFF1F8F5F),
            Color(0x333ECF8E),
            Brand.green,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.radius != radius;
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({required this.role});

  final SpeakerRole role;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Brand.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Brand.surfaceHigh),
          ),
          child: FittedBox(child: role.leading),
        ),
        const SizedBox(width: 28),
        Flexible(
          child: Text(
            role.text,
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.link});

  final SpeakerLink link;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: Brand.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Brand.green.withValues(alpha: 0.6), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(link.icon, size: 34, color: Brand.green),
          const SizedBox(width: 12),
          Text(
            link.text,
            style: const TextStyle(
              fontFamily: Brand.monospaceFontFamily,
              fontSize: 32,
              color: Brand.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades [child] in, sliding it from the right unless [slide] is false, after
/// the elements before it in the [order].
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.order,
    required this.child,
    this.slide = true,
  });

  final int order;
  final bool slide;
  final Widget child;

  static const _step = Duration(milliseconds: 120);
  static const _duration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final total = _step * order + _duration;
    final start = (_step * order).inMicroseconds / total.inMicroseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: slide
            ? Transform.translate(
                offset: Offset(48 * (1 - value), 0),
                child: child,
              )
            : Transform.scale(scale: 0.9 + 0.1 * value, child: child),
      ),
      child: child,
    );
  }
}
