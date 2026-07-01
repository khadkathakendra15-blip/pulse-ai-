import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme/colors.dart';

/// Standard rounded card used everywhere (#0F1318 + 1px hairline).
class CardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color? border;
  final Gradient? gradient;
  const CardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.color = C.card,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? C.line, width: 1),
      ),
      child: child,
    );
  }
}

/// Blurred radial glow blob behind hero rings.
class GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double blur;
  const GlowBlob({super.key, required this.size, required this.color, this.opacity = .28, this.blur = 32});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), Colors.transparent],
              stops: const [0, .62],
            ),
          ),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;
  final double size;
  final bool glow;
  const Dot(this.color, {super.key, this.size = 7, this.glow = true});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: glow ? [BoxShadow(color: color, blurRadius: 7)] : null,
        ),
      );
}

/// Small rounded pill (label chip).
class Pill extends StatelessWidget {
  final Widget child;
  final Color bg;
  final Color? border;
  final EdgeInsets padding;
  const Pill({
    super.key,
    required this.child,
    required this.bg,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: border == null ? null : Border.all(color: border!, width: 1),
        ),
        child: child,
      );
}

/// 7-day mini trend chart (bottom-aligned bars).
class MiniBars extends StatelessWidget {
  final List<Bar> bars;
  final double height;
  const MiniBars(this.bars, {super.key, this.height = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            Expanded(
              child: Container(
                height: height * (bars[i].heightPct / 100),
                decoration: BoxDecoration(
                  color: bars[i].color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
            ),
            if (i != bars.length - 1) const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}

/// Thin progress track + fill (energy slots, illness risk, etc).
class TrackBar extends StatelessWidget {
  final double pct; // 0..100
  final Color color;
  final double height;
  final double opacity;
  const TrackBar(this.pct, this.color, {super.key, this.height = 5, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: C.whiteT(.07),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (pct / 100).clamp(0, 1),
          child: Container(color: color.withValues(alpha: opacity)),
        ),
      ),
    );
  }
}
