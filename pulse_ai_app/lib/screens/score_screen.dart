import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/common.dart';
import '../widgets/rings.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

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
        _donut(d, np),
        const SizedBox(height: 18),
        Text('Signal breakdown', style: F.display(size: 15.5, weight: FontWeight.w700, color: C.textHi)),
        const SizedBox(height: 12),
        for (final c in d.scoreComponents) ...[_component(c), const SizedBox(height: 10)],
        const SizedBox(height: 4),
        _whyScore(app, d, np),
      ],
    );
  }

  Widget _title() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ANALYSIS', style: F.body(size: 12, weight: FontWeight.w700, color: C.dim7, letterSpacing: .8)),
        const SizedBox(height: 2),
        Text('Health Score', style: F.display(size: 25, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.5)),
      ]);

  Widget _donut(d, bool np) => CardBox(
        radius: 32,
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0E201C), Color(0xFF0C1419), Color(0xFF090D12)],
        ),
        child: Column(children: [
          SizedBox(
            width: 210, height: 210,
            child: Stack(alignment: Alignment.center, children: [
              const GlowBlob(size: 210, color: C.accent, opacity: .2, blur: 36),
              ProgressRing(
                size: 210,
                arcs: const [
                  RingArc(radius: 90, strokeWidth: 16, percent: 92, color: C.accent, trackColor: Color(0x0FFFFFFF)),
                ],
                center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('HEALTH', style: F.body(size: 11, weight: FontWeight.w700, color: C.dim6, letterSpacing: 1.5)),
                  Text('92', style: F.display(size: 80, weight: FontWeight.w700, color: Colors.white, height: 1, letterSpacing: -4)),
                  Text('out of 100', style: F.body(size: 13, weight: FontWeight.w600, color: C.dim6)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Text(d.scoreCaption,
              textAlign: TextAlign.center,
              style: F.briefed(np, size: 15, weight: FontWeight.w700, color: C.accent)),
          const SizedBox(height: 4),
          Text('6 signals · Updated every 5 min', style: F.body(size: 12.5, weight: FontWeight.w500, color: C.dim6)),
        ]),
      );

  Widget _component(ScoreComponent c) => CardBox(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          ProgressRing(
            size: 48,
            arcs: [RingArc(radius: 20, strokeWidth: 5, percent: c.score.toDouble(), color: c.color, trackColor: C.whiteT(.07), glow: false)],
            center: Text('${c.score}', style: F.display(size: 13, weight: FontWeight.w700, color: C.textHi)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.label, style: F.body(size: 15, weight: FontWeight.w700, color: C.textHi)),
              const SizedBox(height: 3),
              Text(c.detail, style: F.body(size: 12, weight: FontWeight.w500, color: C.dim6)),
              const SizedBox(height: 5),
              Row(children: [
                Text('base ${c.baseline}', style: F.body(size: 11, weight: FontWeight.w600, color: C.dim7)),
                const SizedBox(width: 8),
                Pill(
                  bg: C.accentT(.09),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text('${c.conf}% conf', style: F.display(size: 10.5, weight: FontWeight.w700, color: C.accent)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(c.dval, style: F.display(size: 13, weight: FontWeight.w700, color: c.dcolor)),
            const SizedBox(height: 2),
            Text('vs avg', style: F.body(size: 11, weight: FontWeight.w600, color: C.dim7)),
          ]),
        ]),
      );

  Widget _whyScore(AppState app, d, bool np) => GestureDetector(
        onTap: app.toggleWhyScore,
        child: CardBox(
          radius: 22,
          border: C.amberT(.18),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF17140F), Color(0xFF13100C)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36, height: 36, alignment: Alignment.center,
                decoration: BoxDecoration(color: C.amberT(.1), borderRadius: BorderRadius.circular(12)),
                child: Text('?', style: F.display(size: 20, weight: FontWeight.w700, color: C.amber)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.whyScoreTitle, style: F.briefed(np, size: 14.5, weight: FontWeight.w700, color: C.textHi)),
                  const SizedBox(height: 1),
                  Text(d.whyScoreSub, style: F.briefed(np, size: 12, color: C.dim4)),
                ]),
              ),
              AnimatedRotation(
                turns: app.whyScoreOpen ? .5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.keyboard_arrow_down, color: C.amber, size: 22),
              ),
            ]),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 14),
                Text(d.whyScoreText, style: F.briefed(np, size: 14, color: C.text3, height: 1.65)),
                const SizedBox(height: 8),
                Text('Sleep 30% · HRV 25% · Heart 20% · Stress 10% · Activity 10% · Recovery 5%',
                    style: F.body(size: 12.5, color: C.dim7, height: 1.5)),
              ]),
              crossFadeState: app.whyScoreOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ]),
        ),
      );
}
