import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/common.dart';
import '../widgets/rings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final d = app.data;
    final np = app.nepali;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        _header(d, np, app.bandLive),
        const SizedBox(height: 18),
        _heroRing(d, np),
        const SizedBox(height: 12),
        _scoreTrio(),
        const SizedBox(height: 14),
        _morningBrief(d, np),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Signals", style: F.display(size: 16, weight: FontWeight.w700, color: C.textHi)),
            Text('All metrics', style: F.body(size: 12.5, weight: FontWeight.w700, color: C.accent)),
          ],
        ),
        const SizedBox(height: 12),
        _vitalsGrid(d.vitals, np),
        const SizedBox(height: 16),
        _mission(d, np),
        const SizedBox(height: 14),
        _predictive(d, np),
        const SizedBox(height: 14),
        _whyCard(context, app, d, np),
      ],
    );
  }

  Widget _header(d, bool np, bool live) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAT · JUN 28',
                      style: F.body(size: 12, weight: FontWeight.w700, color: C.dim7, letterSpacing: .8)),
                  const SizedBox(height: 1),
                  Text(d.greeting,
                      style: (np ? F.np : F.display)(size: 24, weight: FontWeight.w800, color: C.textHi, letterSpacing: -.4)),
                ],
              ),
            ),
            Pill(
              bg: C.accentT(.10),
              border: C.accentT(.22),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Dot(C.accent, size: 7),
                const SizedBox(width: 6),
                Text(live ? 'Band Live' : 'Demo',
                    style: F.display(size: 11.5, weight: FontWeight.w700, color: C.accent)),
              ]),
            ),
          ],
        ),
      );

  Widget _heroRing(d, bool np) => CardBox(
        radius: 32,
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0E201C), Color(0xFF0C1419), Color(0xFF090D12)],
        ),
        child: Column(children: [
          SizedBox(
            width: 240, height: 240,
            child: Stack(alignment: Alignment.center, children: [
              const Positioned(top: 6, child: GlowBlob(size: 230, color: C.accent, opacity: .28)),
              ProgressRing(
                size: 240,
                arcs: const [
                  RingArc(radius: 104, strokeWidth: 14, percent: 89, color: C.accent, trackColor: Color(0x0DFFFFFF)),
                  RingArc(radius: 82, strokeWidth: 10, percent: 84, color: C.blue, trackColor: Color(0x0AFFFFFF)),
                ],
                center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('RECOVERY', style: F.body(size: 11, weight: FontWeight.w700, color: C.dim6, letterSpacing: 2)),
                  Text('89', style: F.display(size: 76, weight: FontWeight.w700, color: Colors.white, height: 1, letterSpacing: -3.8)),
                  Text(np ? 'उत्कृष्ट ✦' : 'Excellent ✦',
                      style: (np ? F.np : F.body)(size: 14, weight: FontWeight.w700, color: C.accent)),
                  const SizedBox(height: 8),
                  Pill(
                    bg: C.blueT(.11), border: C.blueT(.22),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Readiness', style: F.body(size: 11, weight: FontWeight.w600, color: C.dim2)),
                      const SizedBox(width: 6),
                      Text('84', style: F.display(size: 15, weight: FontWeight.w700, color: C.blue)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legend(C.accent, 'Recovery'),
            const SizedBox(width: 20),
            _legend(C.blue, 'Readiness'),
          ]),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(d.heroCaption,
                textAlign: TextAlign.center,
                style: F.briefed(np, size: 14, color: const Color(0xFF8E979F), height: 1.55)),
          ),
        ]),
      );

  Widget _legend(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 3, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: F.body(size: 11.5, weight: FontWeight.w600, color: C.dim3)),
      ]);

  Widget _scoreTrio() => Row(children: [
        _trioCard('HEALTH', '92', 'Excellent', C.accent),
        const SizedBox(width: 10),
        _trioCard('BODY AGE', '22.8', '−2.2 yrs', C.blue),
        const SizedBox(width: 10),
        _trioCard('ENERGY', '78%', 'til 6 PM', C.amber),
      ]);

  Widget _trioCard(String label, String value, String sub, Color subColor) => Expanded(
        child: CardBox(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(children: [
            Text(label, style: F.body(size: 10, weight: FontWeight.w700, color: C.dim6, letterSpacing: .7)),
            const SizedBox(height: 5),
            Text(value, style: F.display(size: 30, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.9)),
            const SizedBox(height: 3),
            Text(sub, style: F.body(size: 11, weight: FontWeight.w700, color: subColor)),
          ]),
        ),
      );

  Widget _morningBrief(d, bool np) => CardBox(
        radius: 26,
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF131921), Color(0xFF0E1319)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: const LinearGradient(colors: [C.accent, Color(0xFF16B87C)]),
              ),
              child: const Icon(Icons.wb_sunny_outlined, size: 17, color: Color(0xFF04130D)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Morning Brief', style: F.display(size: 14, weight: FontWeight.w700, color: C.textHi)),
                Text('AI · 6:08 AM · Personalized', style: F.display(size: 11, color: C.dim7)),
              ]),
            ),
            Pill(bg: C.accentT(.10), border: C.accentT(.2),
                child: Text('Live', style: F.display(size: 11, weight: FontWeight.w700, color: C.accent))),
          ]),
          const SizedBox(height: 13),
          Text(d.morningBriefMain, style: F.briefed(np, size: 15.5, color: C.text2, height: 1.68)),
          const SizedBox(height: 6),
          Text(d.morningBriefAction,
              style: F.briefed(np, size: 15.5, weight: FontWeight.w700, color: C.accent, height: 1.5)),
          if (d.morningBriefEng.toString().isNotEmpty) ...[
            const SizedBox(height: 11),
            const Divider(height: 1, color: C.lineSoft),
            const SizedBox(height: 11),
            Text(d.morningBriefEng, style: F.body(size: 12.5, color: C.dim7, height: 1.5)),
          ],
        ]),
      );

  Widget _vitalsGrid(List<Vital> vitals, bool np) => LayoutBuilder(builder: (context, c) {
        const gap = 11.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap, runSpacing: gap,
          children: [for (final v in vitals) SizedBox(width: w, child: _vitalCard(v, np))],
        );
      });

  Widget _vitalCard(Vital v, bool np) => CardBox(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Dot(v.color, size: 7),
            const SizedBox(width: 6),
            Expanded(child: Text(v.label, style: F.body(size: 11, weight: FontWeight.w700, color: C.dim3, letterSpacing: .5))),
            Pill(
              bg: C.accentT(.10),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text('${v.conf}%', style: F.display(size: 10, weight: FontWeight.w700, color: C.accent)),
            ),
          ]),
          const SizedBox(height: 9),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(v.value, style: F.display(size: 25, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.5)),
            const SizedBox(width: 4),
            Text(v.unit, style: F.body(size: 12, weight: FontWeight.w600, color: C.dim6)),
          ]),
          const SizedBox(height: 7),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${v.arrow} ${v.delta}',
                style: F.display(size: 11.5, weight: FontWeight.w700, color: v.deltaColor)),
            const SizedBox(width: 8),
            Expanded(child: MiniBars(v.bars)),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            Text('avg ${v.avg}', style: F.body(size: 11, color: C.dim7)),
            const SizedBox(width: 6),
            const Dot(C.dim7, size: 3, glow: false),
            const SizedBox(width: 6),
            Text('base ${v.baseline}', style: F.body(size: 11, color: C.dim7)),
          ]),
          const SizedBox(height: 7),
          const Divider(height: 1, color: C.lineFaint),
          const SizedBox(height: 7),
          Text(v.interp, style: F.briefed(np, size: 12, color: C.dim5, height: 1.4)),
        ]),
      );

  Widget _mission(d, bool np) => CardBox(
        radius: 26,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('AI Mission · Today', style: F.display(size: 15.5, weight: FontWeight.w700, color: C.textHi)),
            Pill(bg: C.accentT(.12),
                child: Text('1 / 3', style: F.display(size: 12, weight: FontWeight.w700, color: C.accent))),
          ]),
          const SizedBox(height: 4),
          Text(d.missionSubtitle, style: F.briefed(np, size: 12.5, weight: FontWeight.w600, color: C.dim7)),
          const SizedBox(height: 6),
          for (final m in d.mission) _missionRow(m, np),
        ]),
      );

  Widget _missionRow(Mission m, bool np) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.lineFaint))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26, height: 26, margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: m.done ? C.accent : Colors.transparent,
              border: Border.all(color: m.done ? C.accent : C.whiteT(.15), width: 2),
            ),
            child: m.done
                ? const Icon(Icons.check, size: 13, color: Color(0xFF03100A))
                : null,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.label, style: F.body(size: 14.5, weight: FontWeight.w700, color: m.done ? C.textHi : C.dim1)),
              const SizedBox(height: 2),
              Text(m.reason, style: F.briefed(np, size: 12.5, color: C.dim7, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(m.prog, style: F.display(size: 12, weight: FontWeight.w700, color: C.dim7)),
          ),
        ]),
      );

  Widget _predictive(d, bool np) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: CardBox(
            radius: 22,
            border: C.accentT(.18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0E201C), Color(0xFF0C1419)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOMORROW', style: F.body(size: 10.5, weight: FontWeight.w700, color: C.dim6, letterSpacing: .7)),
              const SizedBox(height: 8),
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
            border: C.accentT(.10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0F1D19), Color(0xFF0C1419)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ILLNESS RISK', style: F.body(size: 10.5, weight: FontWeight.w700, color: C.dim6, letterSpacing: .7)),
              const SizedBox(height: 8),
              Text('Low', style: F.display(size: 28, weight: FontWeight.w700, color: C.accent, height: 1.2, letterSpacing: -.5)),
              const SizedBox(height: 5),
              Text('HRV + Temp normal', style: F.body(size: 12, weight: FontWeight.w600, color: C.dim2)),
              const SizedBox(height: 9),
              const TrackBar(18, C.accent),
            ]),
          ),
        ),
      ]);

  Widget _whyCard(BuildContext context, AppState app, d, bool np) => GestureDetector(
        onTap: app.toggleWhy,
        child: CardBox(
          radius: 24,
          border: C.amberT(.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF17140F), Color(0xFF13100C)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 38, height: 38, alignment: Alignment.center,
                decoration: BoxDecoration(color: C.amberT(.11), borderRadius: BorderRadius.circular(13)),
                child: Text('?', style: F.display(size: 22, weight: FontWeight.w700, color: C.amber)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.whyCardTitle, style: F.briefed(np, size: 15, weight: FontWeight.w700, color: C.textHi)),
                  const SizedBox(height: 1),
                  Text(d.whyCardSub, style: F.briefed(np, size: 12.5, color: C.dim4)),
                ]),
              ),
              AnimatedRotation(
                turns: app.whyOpen ? .5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.keyboard_arrow_down, color: C.amber, size: 24),
              ),
            ]),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _whyExpanded(d, np),
              crossFadeState: app.whyOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ]),
        ),
      );

  Widget _whyExpanded(d, bool np) {
    Widget q(String tag, String body, {Color? bg, Color? valColor}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(color: bg ?? C.whiteT(.04), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tag, style: F.body(size: 10, weight: FontWeight.w700, color: C.dim7, letterSpacing: .8)),
            const SizedBox(height: 5),
            Text(body, style: F.briefed(np, size: 13, weight: FontWeight.w700, color: valColor ?? C.textHi)),
          ]),
        );
    Widget factor(IconData ic, Color icColor, String label, String value, Color valColor, String pts) => Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(color: C.whiteT(.03), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 28, height: 28, alignment: Alignment.center,
              decoration: BoxDecoration(color: icColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
              child: Icon(ic, size: 14, color: icColor),
            ),
            const SizedBox(width: 11),
            Expanded(child: Text(label, style: F.briefed(np, size: 13.5, weight: FontWeight.w600, color: C.dim1))),
            Text(value, style: F.display(size: 14, weight: FontWeight.w700, color: valColor)),
            const SizedBox(width: 8),
            Text(pts, style: F.display(size: 12, weight: FontWeight.w700, color: valColor)),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: q('WHAT', d.whyWhat)),
        const SizedBox(width: 8),
        Expanded(child: q('WHY', d.whyWhy)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: q('WHAT NEXT', d.whyNext, bg: C.accentT(.07), valColor: C.accent)),
        const SizedBox(width: 8),
        Expanded(child: q('WHAT TO DO', d.whyTodo)),
      ]),
      const SizedBox(height: 8),
      factor(Icons.home_outlined, C.accent, d.factor1Label, '8h 12m ↑', C.accent, '+28 pts'),
      factor(Icons.show_chart, C.accent, d.factor2Label, '68ms ↑', C.accent, '+22 pts'),
      factor(Icons.favorite_border, C.blue, d.factor3Label, '58 bpm ↓', C.blue, '+19 pts'),
      const SizedBox(height: 11),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: C.accentT(.07), borderRadius: BorderRadius.circular(14)),
        child: Text(d.whyConclusion, style: F.briefed(np, size: 13.5, color: C.text3, height: 1.55)),
      ),
    ]);
  }
}
