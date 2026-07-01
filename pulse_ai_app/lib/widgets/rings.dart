import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One arc in a [ProgressRing] — a track + a coloured progress stroke,
/// reproducing the mockup's `<circle stroke-dasharray="89 100" pathLength=100>`.
class RingArc {
  final double radius; // px in the painter's coordinate space
  final double strokeWidth;
  final double percent; // 0..100
  final Color color;
  final Color trackColor;
  final bool glow;
  const RingArc({
    required this.radius,
    required this.strokeWidth,
    required this.percent,
    required this.color,
    this.trackColor = const Color(0x0DFFFFFF),
    this.glow = true,
  });
}

/// Concentric progress rings, animated in like the mockup's `ringin` keyframe.
class ProgressRing extends StatefulWidget {
  final double size;
  final List<RingArc> arcs;
  final Widget? center;
  const ProgressRing({super.key, required this.size, required this.arcs, this.center});

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: const Cubic(0.2, 1, 0.35, 1));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _a,
            builder: (_, __) => CustomPaint(
              size: Size.square(widget.size),
              painter: _RingPainter(widget.arcs, _a.value),
            ),
          ),
          if (widget.center != null) widget.center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<RingArc> arcs;
  final double t; // animation 0..1
  _RingPainter(this.arcs, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const start = -math.pi / 2; // rotate(-90deg)
    for (final a in arcs) {
      final track = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.strokeWidth
        ..color = a.trackColor
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, a.radius, track);

      final sweep = 2 * math.pi * (a.percent / 100) * t;
      final rect = Rect.fromCircle(center: center, radius: a.radius);
      if (a.glow) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = a.strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = a.color.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawArc(rect, start, sweep, false, glow);
      }
      final prog = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = a.color;
      canvas.drawArc(rect, start, sweep, false, prog);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.t != t || old.arcs != arcs;
}
