import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/common.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final d = app.data;
    final np = app.nepali;

    return Column(children: [
      _header(app, np),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          physics: const BouncingScrollPhysics(),
          itemCount: app.messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => _bubble(app.messages[i], np),
        ),
      ),
      _composer(app, d, np),
    ]);
  }

  Widget _header(AppState app, bool np) => Container(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        child: Row(children: [
          Container(
            width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [C.accent, Color(0xFF0D7A55)],
              ),
            ),
            child: const Icon(Icons.star_rounded, size: 26, color: Color(0xFF04130D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Pulse Coach', style: F.display(size: 18, weight: FontWeight.w700, color: C.textHi)),
              Row(children: [
                const Dot(C.accent, size: 7, glow: false),
                const SizedBox(width: 5),
                Text('AI health companion · always on',
                    style: F.body(size: 12, weight: FontWeight.w600, color: C.dim2)),
              ]),
            ]),
          ),
          _langToggle(app, np),
        ]),
      );

  Widget _langToggle(AppState app, bool np) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: C.whiteT(.08)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _langChip('नेपाली', np, () => app.setNepali(true), nepali: true),
          _langChip('EN', !np, () => app.setNepali(false), nepali: false),
        ]),
      );

  Widget _langChip(String label, bool active, VoidCallback onTap, {required bool nepali}) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? C.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(label,
              style: (nepali ? F.np : F.display)(
                  size: 12, weight: FontWeight.w700, color: active ? const Color(0xFF04130D) : C.dim2)),
        ),
      );

  Widget _bubble(ChatMessage m, bool np) {
    switch (m.kind) {
      case MsgKind.userText:
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [C.accent, Color(0xFF16B87C)]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22), topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22), bottomRight: Radius.circular(5),
                ),
              ),
              child: Text(m.text,
                  style: F.briefed(np, size: 15, weight: FontWeight.w600, color: const Color(0xFF02100A), height: 1.52)),
            ),
          ),
        );
      case MsgKind.aiText:
        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: C.card,
                border: Border.all(color: C.line),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22), topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(5), bottomRight: Radius.circular(22),
                ),
              ),
              child: Text(m.text, style: F.briefed(np, size: 15, color: const Color(0xFFDCE1E6), height: 1.6)),
            ),
          ),
        );
      case MsgKind.aiAnalysis:
        return Align(alignment: Alignment.centerLeft, child: _analysis(m, np));
    }
  }

  Widget _analysis(ChatMessage m, bool np) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            border: Border.all(color: C.line),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22), topRight: Radius.circular(22),
              bottomLeft: Radius.circular(5), bottomRight: Radius.circular(22),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title, style: F.briefed(np, size: 14.5, weight: FontWeight.w700, color: C.textHi)),
            const SizedBox(height: 12),
            for (final c in m.chips) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: C.whiteT(.04), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Dot(c.color, size: 7, glow: false),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c.l, style: F.body(size: 13, weight: FontWeight.w600, color: C.dim1))),
                  Text('${c.v} ${c.arrow}', style: F.display(size: 14, weight: FontWeight.w700, color: c.color)),
                ]),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(color: C.accentT(.08), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('RECOMMENDATION', style: F.body(size: 10.5, weight: FontWeight.w700, color: C.accent, letterSpacing: 1)),
                const SizedBox(height: 5),
                Text(m.rec, style: F.briefed(np, size: 14, color: const Color(0xFFE0E5EA), height: 1.55)),
              ]),
            ),
            const SizedBox(height: 11),
            const Divider(height: 1, color: C.lineSoft),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('EXPECTED OUTCOME', style: F.body(size: 10, weight: FontWeight.w700, color: C.dim5, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(m.outcome, style: F.briefed(np, size: 13, color: C.text3, height: 1.45)),
                ]),
              ),
              const SizedBox(width: 12),
              Pill(
                bg: C.accentT(.1), border: C.accentT(.2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(children: [
                  Text('AI CONF', style: F.body(size: 9.5, weight: FontWeight.w700, color: C.dim3, letterSpacing: .6)),
                  const SizedBox(height: 3),
                  Text('${m.conf}%', style: F.display(size: 20, weight: FontWeight.w700, color: C.accent, height: 1.1)),
                ]),
              ),
            ]),
          ]),
        ),
      );

  Widget _composer(AppState app, d, bool np) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: d.quicks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final QuickPrompt q = d.quicks[i];
                return GestureDetector(
                  onTap: () => app.ask(q),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: C.whiteT(.09)),
                    ),
                    child: Text(q.label, style: F.briefed(np, size: 13, weight: FontWeight.w600, color: C.text3)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: C.whiteT(.09)),
            ),
            child: Row(children: [
              Expanded(child: Text(d.inputPlaceholder, style: F.briefed(np, size: 15, color: C.dim7))),
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, size: 19, color: Color(0xFF04130D)),
              ),
            ]),
          ),
        ]),
      );
}
