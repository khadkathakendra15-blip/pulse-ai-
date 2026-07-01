import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/common.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
        _weeklyStory(d, np),
        const SizedBox(height: 14),
        _monthly(d),
        const SizedBox(height: 14),
        _energy(d, np),
        const SizedBox(height: 14),
        _burnout(d, np),
        const SizedBox(height: 14),
        _calendar(d),
      ],
    );
  }

  Widget _title() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('INSIGHTS', style: F.body(size: 12, weight: FontWeight.w700, color: C.dim7, letterSpacing: .8)),
        const SizedBox(height: 2),
        Text('Your Story', style: F.display(size: 25, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.5)),
      ]);

  Widget _stat(String v, Color color, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(color: C.whiteT(.03), borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(v, style: F.display(size: 20, weight: FontWeight.w700, color: color)),
            const SizedBox(height: 3),
            Text(label, style: F.body(size: 11, weight: FontWeight.w600, color: C.dim3)),
          ]),
        ),
      );

  Widget _weeklyStory(d, bool np) => CardBox(
        radius: 28,
        border: C.accentT(.14),
        padding: const EdgeInsets.all(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF111F1B), Color(0xFF0D1519)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("This Week's Health Story", style: F.display(size: 14, weight: FontWeight.w700, color: C.textHi)),
              const SizedBox(height: 2),
              Text('Jun 22 – Jun 28', style: F.body(size: 11.5, weight: FontWeight.w600, color: C.dim7)),
            ]),
            Text('Share ↗', style: F.body(size: 12.5, weight: FontWeight.w700, color: C.accent)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _stat('↑ 12%', C.accent, 'Recovery'),
            const SizedBox(width: 9),
            _stat('+42m', C.purple, 'Sleep avg'),
            const SizedBox(width: 9),
            _stat('↓ 15%', C.blue, 'Stress'),
          ]),
          const SizedBox(height: 16),
          Text(d.weeklyStory, style: F.briefed(np, size: 15, color: const Color(0xFFC4CAD0), height: 1.7)),
          const SizedBox(height: 12),
          Text(d.weeklyConclusion, style: F.briefed(np, size: 15, weight: FontWeight.w700, color: C.accent)),
        ]),
      );

  Widget _monthly(d) => CardBox(
        radius: 26,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('June Highlights', style: F.display(size: 15, weight: FontWeight.w700, color: C.textHi)),
          const SizedBox(height: 14),
          for (var i = 0; i < d.monthlyHighlights.length; i++) ...[
            if (i != 0) const SizedBox(height: 12),
            _highlight(d.monthlyHighlights[i]),
          ],
        ]),
      );

  Widget _highlight(Highlight h) => Row(children: [
        Container(
          width: 34, height: 34, alignment: Alignment.center,
          decoration: BoxDecoration(color: h.iconBg, borderRadius: BorderRadius.circular(12)),
          child: Text(h.icon, style: const TextStyle(fontSize: 17)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.title, style: F.body(size: 13.5, weight: FontWeight.w700, color: C.textHi)),
            const SizedBox(height: 2),
            Text(h.sub, style: F.body(size: 12, color: C.dim6)),
          ]),
        ),
        Text(h.val, style: F.display(size: 14, weight: FontWeight.w700, color: h.valColor)),
      ]);

  Widget _energy(d, bool np) => CardBox(
        radius: 26,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Energy Forecast', style: F.display(size: 15, weight: FontWeight.w700, color: C.textHi)),
            Pill(bg: C.coralT(.12), child: Text('Dip 2–4 PM', style: F.body(size: 12, weight: FontWeight.w700, color: C.coral))),
          ]),
          const SizedBox(height: 14),
          for (var i = 0; i < d.energySlots.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            _slot(d.energySlots[i], np),
          ],
        ]),
      );

  Widget _slot(EnergySlot s, bool np) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: C.whiteT(.025),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.whiteT(.055)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(s.time, style: F.display(size: 13, weight: FontWeight.w700, color: C.textHi)),
                Text('${s.pct}%', style: F.display(size: 13, weight: FontWeight.w700, color: s.color)),
              ]),
              const SizedBox(height: 3),
              Text(s.label, style: F.briefed(np, size: 13, weight: FontWeight.w600, color: C.dim3)),
              const SizedBox(height: 6),
              TrackBar(s.pct.toDouble(), s.color, height: 3, opacity: .8),
            ]),
          ),
        ]),
      );

  Widget _burnout(d, bool np) => CardBox(
        radius: 26,
        border: C.coralT(.18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF191014), Color(0xFF14101A)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 20, color: C.coral),
            const SizedBox(width: 10),
            Expanded(child: Text('Burnout Radar', style: F.display(size: 15, weight: FontWeight.w700, color: C.textHi))),
            Pill(bg: C.amberT(.14), child: Text('MEDIUM', style: F.body(size: 12, weight: FontWeight.w700, color: C.amber))),
          ]),
          const SizedBox(height: 14),
          _gauge(),
          const SizedBox(height: 16),
          _radarRow('Stress (7-day)', 'Rising ↑', C.coral),
          const SizedBox(height: 9),
          _radarRow('Sleep duration', 'Falling ↓', C.amber),
          const SizedBox(height: 9),
          _radarRow('Recovery trend', 'Falling ↓', C.amber),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: C.whiteT(.04), borderRadius: BorderRadius.circular(14)),
            child: Text(d.burnoutRec, style: F.briefed(np, size: 13.5, color: const Color(0xFFE3E8EC), height: 1.55)),
          ),
        ]),
      );

  Widget _gauge() => SizedBox(
        height: 18,
        child: Stack(clipBehavior: Clip.none, children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(colors: [C.accent, C.amber, C.coral], stops: [0, .52, 1]),
              ),
            ),
          ),
          LayoutBuilder(builder: (context, cstr) {
            return Positioned(
              left: cstr.maxWidth * .53 - 9,
              top: 0,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF14101A), width: 3),
                  boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
              ),
            );
          }),
        ]),
      );

  Widget _radarRow(String label, String value, Color color) => Row(children: [
        Expanded(child: Text(label, style: F.body(size: 13.5, weight: FontWeight.w600, color: C.text3))),
        Text(value, style: F.display(size: 14, weight: FontWeight.w700, color: color)),
      ]);

  Widget _calendar(d) => CardBox(
        radius: 26,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text('Health Calendar · June', style: F.display(size: 15, weight: FontWeight.w700, color: C.textHi))),
            Row(children: [
              _legendDot('Good', const Color(0xD12BE3A0)),
              const SizedBox(width: 10),
              _legendDot('Fair', const Color(0xD1F5B342)),
              const SizedBox(width: 10),
              _legendDot('Low', const Color(0xC7FF6B72)),
            ]),
          ]),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (final CalDay day in d.calendar)
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: day.bg, borderRadius: BorderRadius.circular(9)),
                  child: Text('${day.n}', style: F.display(size: 11, weight: FontWeight.w600, color: day.fg)),
                ),
            ],
          ),
        ]),
      );

  Widget _legendDot(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: F.body(size: 11, color: C.dim2)),
      ]);
}
