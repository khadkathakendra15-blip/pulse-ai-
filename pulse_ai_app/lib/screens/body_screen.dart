import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/common.dart';

class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final d = app.data;
    final np = app.nepali;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        _title(),
        const SizedBox(height: 18),
        _bodyAge(d, np),
        const SizedBox(height: 14),
        const _Twin(),
        const SizedBox(height: 14),
        _forecast(d, np),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Achievements', style: F.display(size: 15.5, weight: FontWeight.w700, color: C.textHi)),
          Text('See all', style: F.body(size: 12.5, weight: FontWeight.w700, color: C.accent)),
        ]),
        const SizedBox(height: 12),
        for (final a in d.achievements) ...[_achievement(a, np), const SizedBox(height: 10)],
        const SizedBox(height: 16),
        _ecosystemHeader(d, np),
        const SizedBox(height: 12),
        _futureGrid(d.futureMods, np),
      ],
    );
  }

  Widget _title() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR BODY', style: F.body(size: 12, weight: FontWeight.w700, color: C.dim7, letterSpacing: .8)),
        const SizedBox(height: 2),
        Text('AI Health Twin', style: F.display(size: 25, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.5)),
      ]);

  Widget _bodyAge(d, bool np) => CardBox(
        radius: 28,
        padding: const EdgeInsets.all(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0F201C), Color(0xFF0D1519)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('BIOLOGICAL AGE', style: F.body(size: 11, weight: FontWeight.w700, color: C.dim6, letterSpacing: .7)),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  Text('22.8', style: F.display(size: 60, weight: FontWeight.w700, color: Colors.white, height: 1, letterSpacing: -3)),
                  const SizedBox(width: 4),
                  Text('yrs', style: F.body(size: 17, weight: FontWeight.w600, color: C.dim6)),
                ]),
                const SizedBox(height: 4),
                Text(d.bodyAgeCaption, style: F.briefed(np, size: 13.5, weight: FontWeight.w700, color: C.accent)),
                const SizedBox(height: 2),
                Text('Better than 78% of peers your age', style: F.body(size: 12, weight: FontWeight.w600, color: C.dim7)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Actual age', style: F.body(size: 11, weight: FontWeight.w600, color: C.dim6)),
              const SizedBox(height: 2),
              Text('25', style: F.display(size: 32, weight: FontWeight.w700, color: C.dim4, letterSpacing: -.5)),
            ]),
          ]),
          const SizedBox(height: 12),
          Text('6-month improvement', style: F.body(size: 12, weight: FontWeight.w600, color: C.dim7)),
          const SizedBox(height: 8),
          SizedBox(height: 72, width: double.infinity, child: CustomPaint(painter: _SparkPainter())),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (final m in ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'])
              Text(m, style: F.display(size: 10.5, weight: FontWeight.w600, color: C.dim7)),
          ]),
        ]),
      );

  Widget _forecast(d, bool np) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: CardBox(
            radius: 22, border: C.accentT(.18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOMORROW', style: F.body(size: 10.5, weight: FontWeight.w700, color: C.dim6, letterSpacing: .6)),
              const SizedBox(height: 7),
              Text('92', style: F.display(size: 46, weight: FontWeight.w700, color: C.accent, height: 1, letterSpacing: -1.8)),
              const SizedBox(height: 5),
              Text('Recovery predicted', style: F.body(size: 12, weight: FontWeight.w600, color: C.dim2)),
              const SizedBox(height: 3),
              Text(d.tmrCaption, style: F.briefed(np, size: 12, color: C.dim7, height: 1.4)),
            ]),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: CardBox(
            radius: 22,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('THIS WEEK AVG', style: F.body(size: 10.5, weight: FontWeight.w700, color: C.dim6, letterSpacing: .6)),
              const SizedBox(height: 7),
              Text('82', style: F.display(size: 46, weight: FontWeight.w700, color: C.amber, height: 1, letterSpacing: -1.8)),
              const SizedBox(height: 5),
              Text('vs last week', style: F.body(size: 12, weight: FontWeight.w600, color: C.dim2)),
              const SizedBox(height: 3),
              Text('↑ 12% improvement', style: F.body(size: 12, weight: FontWeight.w700, color: C.accent)),
            ]),
          ),
        ),
      ]);

  Widget _achievement(Achievement a, bool np) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: a.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: a.border),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(color: a.iconBg, borderRadius: BorderRadius.circular(16)),
            child: Text(a.icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: F.body(size: 14.5, weight: FontWeight.w700, color: a.titleColor)),
              const SizedBox(height: 2),
              Text(a.desc, style: F.briefed(np, size: 12.5, color: C.dim6, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 10),
          Pill(
            bg: a.badgeBg,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(a.badge, style: F.display(size: 11, weight: FontWeight.w700, color: a.badgeColor)),
          ),
        ]),
      );

  Widget _ecosystemHeader(d, bool np) => Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Future Ecosystem', style: F.display(size: 15.5, weight: FontWeight.w700, color: C.textHi)),
            const SizedBox(height: 2),
            Text(d.ecosystemSub, style: F.briefed(np, size: 12.5, color: C.dim7)),
          ]),
        ),
        Text('Waitlist →', style: F.body(size: 12, weight: FontWeight.w700, color: C.accent)),
      ]);

  Widget _futureGrid(List<FutureMod> mods, bool np) => LayoutBuilder(builder: (context, c) {
        const gap = 10.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap, runSpacing: gap,
          children: [
            for (final m in mods)
              SizedBox(
                width: w,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.cardDarker,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: C.line),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 10),
                    Text(m.label, style: F.display(size: 14, weight: FontWeight.w700, color: const Color(0xFF5C6470))),
                    const SizedBox(height: 3),
                    Text(m.desc, style: F.briefed(np, size: 12, color: C.dim8, height: 1.4)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: C.whiteT(.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: C.whiteT(.08)),
                      ),
                      child: Text('Coming Soon', style: F.body(size: 10.5, weight: FontWeight.w700, color: m.color)),
                    ),
                  ]),
                ),
              ),
          ],
        );
      });
}

/// Floating-chip "Health Twin" visualisation.
class _Twin extends StatelessWidget {
  const _Twin();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: C.cardDark,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: C.line),
      ),
      child: Stack(children: [
        const Center(child: GlowBlob(size: 160, color: C.accent, opacity: .13, blur: 40)),
        Positioned(top: 14, left: 20, child: Text('Health Twin', style: F.display(size: 13.5, weight: FontWeight.w700, color: C.textHi))),
        // silhouette
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _limb(42, 42, 21, .24),
            const SizedBox(height: 5),
            _limb(74, 112, 34, .18),
            const SizedBox(height: 5),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _limb(24, 88, 17, .13),
              const SizedBox(width: 14),
              _limb(24, 88, 17, .13),
            ]),
          ]),
        ),
        _chip(top: 40, left: 12, label: 'RECOVERY', value: '89', color: C.accent, big: true),
        _chip(top: 96, right: 12, label: 'HEART', value: '58 bpm', color: C.coral),
        _chip(bottom: 72, left: 10, label: 'STRESS', value: 'Low', color: C.amber),
        _chip(bottom: 28, right: 12, label: 'HRV', value: '68 ms', color: C.blue),
      ]),
    );
  }

  Widget _limb(double w, double h, double r, double borderO) => Container(
        width: w, height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1E2830), Color(0xFF141C23)],
          ),
          border: Border.all(color: C.accentT(borderO), width: 1.5),
        ),
      );

  Widget _chip({double? top, double? bottom, double? left, double? right, required String label, required String value, required Color color, bool big = false}) =>
      Positioned(
        top: top, bottom: bottom, left: left, right: right,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .28)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: F.body(size: 10, weight: FontWeight.w700, color: C.dim3, letterSpacing: .4)),
            Text(value, style: F.display(size: big ? 22 : 14, weight: FontWeight.w700, color: color, letterSpacing: big ? -.5 : 0)),
          ]),
        ),
      );
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // normalised control points from the mockup viewBox (300x72)
    final pts = [
      const Offset(0, 64), const Offset(64, 42), const Offset(124, 19),
      const Offset(184, 10), const Offset(244, 8), const Offset(300, 8),
    ];
    final sx = size.width / 300, sy = size.height / 72;
    final path = Path()..moveTo(pts.first.dx * sx, pts.first.dy * sy);
    for (var i = 1; i < pts.length; i++) {
      final p0 = pts[i - 1], p1 = pts[i];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx * sx, p0.dy * sy, cx * sx, p1.dy * sy, p1.dx * sx, p1.dy * sy);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x522BE3A0), Color(0x002BE3A0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = C.accent,
    );
    canvas.drawCircle(Offset(size.width, 8 * sy), 5, Paint()..color = C.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
