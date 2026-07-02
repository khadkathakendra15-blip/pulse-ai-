import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/rings.dart';

/// Onboarding flow — faithful port of `Pulse AI Onboarding - Standalone`.
/// 9 screens: welcome → pairing → profile → goals → setup → reveal →
/// premium → notifs → done. Pure demo: pairing/setup are simulated.
enum OnbStep { welcome, pairing, profile, goals, setup, reveal, premium, notifs, done }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnbStep step = OnbStep.welcome;
  int pairPhase = 0; // 0=scanning 1=found 2=connected
  bool annual = true;
  String fitness = 'moderate';
  final Map<String, bool> goals = {
    'sleep': true, 'stress': false, 'fitness': true,
    'heart': false, 'weight': false, 'energy': false,
  };
  late final TextEditingController _name = TextEditingController(text: 'Thakendra');
  Timer? _pairTimer;

  static const _order = OnbStep.values;

  void _next() {
    final i = _order.indexOf(step);
    if (i < _order.length - 1) setState(() => step = _order[i + 1]);
  }

  void _pairTap() {
    if (pairPhase < 2) {
      setState(() => pairPhase = 1);
      _pairTimer?.cancel();
      _pairTimer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted) setState(() => pairPhase = 2);
      });
    } else {
      _next();
    }
  }

  @override
  void dispose() {
    _pairTimer?.cancel();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.screenBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(step), child: _screen()),
        ),
      ),
    );
  }

  Widget _screen() {
    switch (step) {
      case OnbStep.welcome: return _welcome();
      case OnbStep.pairing: return _pairing();
      case OnbStep.profile: return _profile();
      case OnbStep.goals: return _goals();
      case OnbStep.setup: return _setup();
      case OnbStep.reveal: return _reveal();
      case OnbStep.premium: return _premium();
      case OnbStep.notifs: return _notifs();
      case OnbStep.done: return _done();
    }
  }

  // ── shared pieces ──────────────────────────────────────────────────────

  /// Fills the viewport but scrolls when the content is taller (short
  /// screens / test surfaces). Keeps Spacer-based layouts intact.
  Widget _fill(Widget child) => LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: IntrinsicHeight(child: child),
          ),
        ),
      );

  /// 7-segment step indicator (screens after welcome).
  Widget _stepBars() {
    const stepScreens = [
      OnbStep.pairing, OnbStep.profile, OnbStep.goals, OnbStep.setup,
      OnbStep.reveal, OnbStep.premium, OnbStep.notifs,
    ];
    final cur = stepScreens.indexOf(step);
    return Row(children: [
      for (var i = 0; i < stepScreens.length; i++) ...[
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: i <= cur ? C.accent : C.whiteT(.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        if (i != stepScreens.length - 1) const SizedBox(width: 6),
      ],
    ]);
  }

  Widget _kicker(String text) => Text(text,
      style: F.body(size: 12, weight: FontWeight.w700, color: C.dim7, letterSpacing: .8));

  Widget _title(String text) => Text(text,
      style: F.display(size: 26, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.7));

  Widget _subNp(String text, {Color? color}) =>
      Text(text, style: F.np(size: 15, color: color ?? C.dim5));

  /// Gradient CTA button (green by default, amber for premium).
  Widget _cta(String label, VoidCallback onTap,
      {String? sub, bool subNp = false, bool amber = false, bool glow = true}) {
    final colors = amber
        ? const [Color(0xFFF5B342), Color(0xFFE09A1A)]
        : const [C.accent, Color(0xFF0CA86A)];
    final fg = amber ? const Color(0xFF0E0900) : const Color(0xFF03100A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(28),
          boxShadow: glow
              ? [BoxShadow(color: colors.first.withValues(alpha: .3), blurRadius: 32, offset: const Offset(0, 8))]
              : null,
        ),
        child: Column(children: [
          Text(label, style: F.display(size: 17, weight: FontWeight.w700, color: fg)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub,
                style: (subNp ? F.np : F.display)(
                    size: 13, color: fg.withValues(alpha: .6), weight: FontWeight.w500)),
          ],
        ]),
      ),
    );
  }

  Widget _ghost(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(label, style: F.body(size: 13, weight: FontWeight.w600, color: C.dim7)),
          ),
        ),
      );

  // ── 1. WELCOME ─────────────────────────────────────────────────────────
  Widget _welcome() {
    final feats = [
      ('🧬', C.accentT(.1), 'AI Recovery Analysis', 'HRV, Sleep, Stress — एकैठाउँ', true),
      ('🧠', C.purpleT(.1), 'Personal AI Coach', 'नेपालीमा health guidance', true),
      ('📈', C.blueT(.1), 'Predictive Insights', 'Recovery forecast + illness risk', false),
    ];
    return _fill(Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Column(children: [
        const Spacer(),
        // Logo mark with pulse rings
        SizedBox(
          width: 110, height: 110,
          child: Stack(alignment: Alignment.center, children: [
            const _PulseRings(size: 110, color: C.accent),
            _Throb(
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [C.accent, Color(0xFF0CA86A)]),
                  boxShadow: [BoxShadow(color: C.accentT(.4), blurRadius: 40)],
                ),
                child: const Icon(Icons.show_chart, size: 38, color: Color(0xFF03100A)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        Text('Pulse AI',
            style: F.display(size: 42, weight: FontWeight.w700, color: C.textHi, letterSpacing: -1.7, height: 1)),
        const SizedBox(height: 10),
        const _Heartbeat(),
        const SizedBox(height: 14),
        Text('Your AI Health Companion',
            style: F.display(size: 17, weight: FontWeight.w500, color: C.dim2)),
        const SizedBox(height: 3),
        Text('तपाईंको AI स्वास्थ्य साथी', style: F.np(size: 17, color: C.dim5)),
        const Spacer(flex: 2),
        // Feature cards
        for (final f in feats) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: C.whiteT(.04),
              border: Border.all(color: C.whiteT(.06)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36, alignment: Alignment.center,
                decoration: BoxDecoration(color: f.$2, borderRadius: BorderRadius.circular(12)),
                child: Text(f.$1, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 13),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.$3, style: F.body(size: 14, weight: FontWeight.w700, color: C.textHi)),
                const SizedBox(height: 1),
                Text(f.$4, style: (f.$5 ? F.np : F.body)(size: 12, color: C.dim5)),
              ]),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        _cta('सुरु गरौं →', _next, sub: "Let's get started"),
        const SizedBox(height: 14),
        Text('Privacy-first · Data stays with you', style: F.body(size: 12, color: C.dim8)),
      ]),
    ));
  }

  // ── 2. PAIRING ─────────────────────────────────────────────────────────
  Widget _pairing() {
    final labels = ['Scanning for H59…', 'Band found — H59-PRO', 'Connected & syncing'];
    final done = pairPhase >= 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepBars(),
        const SizedBox(height: 24),
        _kicker('STEP 1 OF 6'),
        const SizedBox(height: 6),
        _title('Connect your band'),
        const SizedBox(height: 4),
        _subNp('H59 band लाई Bluetooth मार्फत जोड्नुहोस्'),
        Expanded(
          child: Stack(alignment: Alignment.center, children: [
            const _PulseRings(size: 200, color: C.accent, opacity: .12),
            // Band illustration
            Column(mainAxisSize: MainAxisSize.min, children: [
              _strap(top: true),
              Container(
                width: 58, height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2830), Color(0xFF111820)]),
                  border: Border.all(color: C.accentT(.25), width: 2),
                  boxShadow: [BoxShadow(color: C.accentT(.18), blurRadius: 40)],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [C.accent, Color(0xFF0CA86A)]),
                    ),
                    child: const Icon(Icons.show_chart, size: 15, color: Color(0xFF03100A)),
                  ),
                  const SizedBox(height: 6),
                  Container(width: 18, height: 2, color: C.accentT(.4)),
                  const SizedBox(height: 3),
                  Container(width: 14, height: 2, color: C.accentT(.25)),
                ]),
              ),
              _strap(top: false),
            ]),
            // Floating bluetooth chip
            Positioned(
              top: 40, right: 40,
              child: _Throb(
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: C.blueT(.12),
                    border: Border.all(color: C.blueT(.25)),
                  ),
                  child: const Icon(Icons.bluetooth, size: 18, color: C.blue),
                ),
              ),
            ),
            // Status chips
            Positioned(
              bottom: 12, left: 0, right: 0,
              child: Column(children: [
                for (var i = 0; i < 3; i++) _pairChip(i, labels[i]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        done
            ? _cta('Band connected — Continue →', _pairTap)
            : GestureDetector(
                onTap: _pairTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(28)),
                  child: Center(
                    child: Text('Tap to scan',
                        style: F.display(size: 17, weight: FontWeight.w700, color: C.dim2)),
                  ),
                ),
              ),
        _ghost('Skip for now', _next),
      ]),
    );
  }

  Widget _strap({required bool top}) => Container(
        width: 32, height: 22,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A2028), Color(0xFF0E151D)]),
          border: Border.all(color: C.accentT(.15), width: 1.5),
          borderRadius: BorderRadius.vertical(
            top: top ? const Radius.circular(10) : Radius.zero,
            bottom: top ? Radius.zero : const Radius.circular(10),
          ),
        ),
      );

  Widget _pairChip(int i, String label) {
    final chipDone = i == 0 ? pairPhase > 0 : pairPhase > 1;
    final spin = (i == 0 && pairPhase == 0) || (i == 1 && pairPhase == 1);
    final active = (i == 0) || (i == 1 && pairPhase >= 1) || (i == 2 && pairPhase >= 2);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: C.whiteT(.04),
        border: Border.all(color: C.whiteT(.07)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 20, height: 20, alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: chipDone ? C.accent : (spin ? C.accentT(.15) : C.whiteT(.08)),
          ),
          child: chipDone
              ? const Icon(Icons.check, size: 12, color: Color(0xFF03100A))
              : spin
                  ? const SizedBox(
                      width: 11, height: 11,
                      child: CircularProgressIndicator(strokeWidth: 2, color: C.accent))
                  : null,
        ),
        const SizedBox(width: 10),
        Text(label,
            style: F.display(size: 13.5, weight: FontWeight.w600, color: active ? C.textHi : C.dim5)),
      ]),
    );
  }

  // ── 3. PROFILE ─────────────────────────────────────────────────────────
  Widget _profile() {
    Widget field(String label, Widget child) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: F.body(size: 12, weight: FontWeight.w700, color: C.dim5, letterSpacing: .8)),
          const SizedBox(height: 8),
          child,
        ]);
    Widget statCard(Widget inner) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            border: Border.all(color: C.whiteT(.08)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: inner,
        );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepBars(),
        const SizedBox(height: 24),
        _kicker('STEP 2 OF 6'),
        const SizedBox(height: 6),
        _title('About you'),
        const SizedBox(height: 4),
        _subNp('तपाईंको व्यक्तिगत स्वास्थ्य profile बनाउनुहोस्'),
        const SizedBox(height: 28),
        field(
          'YOUR NAME',
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: C.card,
              border: Border.all(color: C.accentT(.3), width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              controller: _name,
              cursorColor: C.accent,
              style: F.display(size: 18, weight: FontWeight.w600, color: C.textHi),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: field('AGE', statCard(Column(children: [
              Text('25', style: F.display(size: 36, weight: FontWeight.w700, color: C.textHi, letterSpacing: -1)),
              const SizedBox(height: 2),
              Text('years', style: F.body(size: 12, color: C.dim5)),
            ]))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: field('GENDER', statCard(Column(children: [
              const Text('♂', style: TextStyle(fontSize: 28, color: C.textHi)),
              const SizedBox(height: 4),
              Text('Male', style: F.body(size: 13, weight: FontWeight.w600, color: C.dim2)),
            ]))),
          ),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: field('HEIGHT', statCard(
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '172 ', style: F.display(size: 30, weight: FontWeight.w700, color: C.textHi)),
                  TextSpan(text: 'cm', style: F.display(size: 16, color: C.dim5)),
                ]),
                textAlign: TextAlign.center,
              ),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: field('WEIGHT', statCard(
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '68 ', style: F.display(size: 30, weight: FontWeight.w700, color: C.textHi)),
                  TextSpan(text: 'kg', style: F.display(size: 16, color: C.dim5)),
                ]),
                textAlign: TextAlign.center,
              ),
            )),
          ),
        ]),
        const SizedBox(height: 24),
        _cta('Continue →', _next),
      ]),
    );
  }

  // ── 4. GOALS ───────────────────────────────────────────────────────────
  Widget _goals() {
    const defs = [
      ('sleep', '😴', 'Better Sleep', 'निद्रा सुधार'),
      ('stress', '🧘', 'Reduce Stress', 'Stress कम गर्ने'),
      ('fitness', '💪', 'Get Fitter', 'Fitness बढाउने'),
      ('heart', '❤️', 'Heart Health', 'मुटुको स्वास्थ्य'),
      ('weight', '⚖️', 'Weight Goal', 'तौल व्यवस्थापन'),
      ('energy', '⚡', 'More Energy', 'Energy बढाउने'),
    ];
    const levels = [('beginner', '🌱', 'Beginner'), ('moderate', '🚶', 'Moderate'), ('active', '🏃', 'Active')];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepBars(),
        const SizedBox(height: 24),
        _kicker('STEP 3 OF 6'),
        const SizedBox(height: 6),
        _title('Your goals'),
        const SizedBox(height: 4),
        _subNp('के improve गर्न चाहनुहुन्छ? (एकभन्दा बढी छान्न मिल्छ)'),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, cc) {
          final w = (cc.maxWidth - 10) / 2;
          return Wrap(spacing: 10, runSpacing: 10, children: [
            for (final g in defs)
              SizedBox(
                width: w,
                child: GestureDetector(
                  onTap: () => setState(() => goals[g.$1] = !(goals[g.$1] ?? false)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: (goals[g.$1] ?? false) ? C.accentT(.1) : C.card,
                      border: Border.all(
                          color: (goals[g.$1] ?? false) ? C.accentT(.4) : C.whiteT(.07), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(children: [
                      Text(g.$2, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(g.$3,
                          style: F.body(
                              size: 13.5, weight: FontWeight.w700,
                              color: (goals[g.$1] ?? false) ? C.textHi : C.dim3)),
                      const SizedBox(height: 3),
                      Text(g.$4, style: F.np(size: 11.5, color: C.dim5)),
                    ]),
                  ),
                ),
              ),
          ]);
        }),
        const SizedBox(height: 22),
        Text('FITNESS LEVEL',
            style: F.body(size: 13, weight: FontWeight.w700, color: C.dim2, letterSpacing: .6)),
        const SizedBox(height: 12),
        Row(children: [
          for (var i = 0; i < levels.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => fitness = levels[i].$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                  decoration: BoxDecoration(
                    color: fitness == levels[i].$1 ? C.accentT(.1) : C.card,
                    border: Border.all(
                        color: fitness == levels[i].$1 ? C.accentT(.4) : C.whiteT(.07), width: 1.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(children: [
                    Text(levels[i].$2, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 5),
                    Text(levels[i].$3,
                        style: F.body(
                            size: 12.5, weight: FontWeight.w700,
                            color: fitness == levels[i].$1 ? C.textHi : C.dim3)),
                  ]),
                ),
              ),
            ),
            if (i != levels.length - 1) const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 22),
        _cta('Continue →', _next),
      ]),
    );
  }

  // ── 5. AI SETUP ────────────────────────────────────────────────────────
  Widget _setup() {
    final steps = [
      ('Analyzing your health profile', 2), // 2=done 1=active 0=waiting
      ('Calibrating AI baselines', 2),
      ('Building your recovery model', 1),
      ('Preparing personalized insights', 0),
    ];
    return _fill(Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 140, height: 140,
          child: Stack(alignment: Alignment.center, children: [
            const _PulseRings(size: 140, color: C.accent, opacity: .18),
            Container(
              width: 90, height: 90, alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF1A2830), Color(0xFF0E1620)]),
                border: Border.all(color: C.accentT(.3), width: 2),
                boxShadow: [BoxShadow(color: C.accentT(.2), blurRadius: 50)],
              ),
              child: const SizedBox(
                width: 32, height: 32,
                child: CircularProgressIndicator(strokeWidth: 3, color: C.accent),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 36),
        Text('Setting up your AI…',
            style: F.display(size: 24, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.7)),
        const SizedBox(height: 8),
        Text('तपाईंको personal health AI\nतयार हुँदैछ…',
            textAlign: TextAlign.center, style: F.np(size: 16, color: C.dim5, height: 1.6)),
        const SizedBox(height: 40),
        for (final s in steps)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: s.$2 == 2 ? C.accentT(.06) : C.whiteT(s.$2 == 1 ? .03 : .02),
              border: Border.all(color: s.$2 == 2 ? C.accentT(.15) : C.whiteT(s.$2 == 1 ? .07 : .05)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              Container(
                width: 28, height: 28, alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.$2 == 2 ? C.accent : (s.$2 == 1 ? C.accentT(.15) : C.whiteT(.08)),
                ),
                child: s.$2 == 2
                    ? const Icon(Icons.check, size: 13, color: Color(0xFF03100A))
                    : s.$2 == 1
                        ? const SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: C.accent))
                        : Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: C.whiteT(.2))),
              ),
              const SizedBox(width: 14),
              Text(s.$1,
                  style: F.display(
                      size: 14, weight: FontWeight.w600,
                      color: s.$2 == 2 ? C.accent : (s.$2 == 1 ? C.textHi : C.dim5))),
            ]),
          ),
        const SizedBox(height: 24),
        _cta('See my first insight →', _next),
      ]),
    ));
  }

  // ── 6. REVEAL (first insight) ──────────────────────────────────────────
  Widget _reveal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepBars(),
        const SizedBox(height: 24),
        _kicker('YOUR FIRST AI INSIGHT'),
        const SizedBox(height: 6),
        _title('Good morning!'),
        const SizedBox(height: 4),
        Text('तपाईंको पहिलो Health Report तयार छ ✦',
            style: F.np(size: 15, weight: FontWeight.w700, color: C.accent)),
        const SizedBox(height: 22),
        // Recovery ring card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0E201C), Color(0xFF0C1419)]),
            border: Border.all(color: C.accentT(.18)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(children: [
            ProgressRing(
              size: 78,
              arcs: const [RingArc(radius: 32, strokeWidth: 10, percent: 78, color: C.accent)],
              center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('78', style: F.display(size: 24, weight: FontWeight.w700, color: Colors.white, height: 1, letterSpacing: -1)),
                Text('GOOD', style: F.body(size: 9, weight: FontWeight.w700, color: C.accent)),
              ]),
            ),
            const SizedBox(width: 18),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recovery Score', style: F.display(size: 13, weight: FontWeight.w600, color: C.dim5)),
              const SizedBox(height: 4),
              Text('78 / 100', style: F.display(size: 22, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.4)),
              const SizedBox(height: 3),
              Text('राम्रो सुरुवात — पहिलो दिन!', style: F.np(size: 13, color: C.dim2)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        // First morning brief
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF131921), Color(0xFF0E1319)]),
            border: Border.all(color: C.line),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [C.accent, Color(0xFF16B87C)]),
                ),
                child: const Icon(Icons.wb_sunny_outlined, size: 15, color: Color(0xFF04130D)),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('First Morning Brief', style: F.display(size: 13, weight: FontWeight.w700, color: C.textHi)),
                Text('AI · Just now · Personalized for you', style: F.display(size: 11, color: C.dim7)),
              ]),
            ]),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: 'नमस्ते ठाकेन्द्र! Pulse AI मा स्वागत छ। तपाईंको H59 band ले पहिलो रात राम्रो data collect गर्यो। ',
                    style: F.np(size: 15.5, color: C.text2, height: 1.68)),
                TextSpan(
                    text: 'Recovery ७८',
                    style: F.np(size: 15.5, weight: FontWeight.w700, color: C.accent, height: 1.68)),
                TextSpan(
                    text: ' — पहिलो दिनका लागि यो उत्कृष्ट सुरुवात हो।',
                    style: F.np(size: 15.5, color: C.text2, height: 1.68)),
              ]),
            ),
            const SizedBox(height: 6),
            Text('आज हल्का walk र राम्रो निद्रा — भोलि Recovery ८५+ हुनेछ। 🌟',
                style: F.np(size: 15.5, weight: FontWeight.w700, color: C.accent)),
          ]),
        ),
        const SizedBox(height: 14),
        // First mission
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            border: Border.all(color: C.whiteT(.06)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your First Mission', style: F.display(size: 13, weight: FontWeight.w700, color: C.textHi)),
            const SizedBox(height: 11),
            for (final m in ['🚶 ३०-मिनेट walk गर्नुहोस्', '💧 २L पानी पिउनुहोस्', '😴 रात ११ अघि सुत्नुहोस्'])
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, border: Border.all(color: C.accentT(.35), width: 2)),
                  ),
                  const SizedBox(width: 11),
                  Text(m, style: F.np(size: 14, weight: FontWeight.w600, color: C.dim1)),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 20),
        _cta('Unlock full experience →', _next),
      ]),
    );
  }

  // ── 7. PREMIUM ─────────────────────────────────────────────────────────
  Widget _premium() {
    const feats = [
      ('📊', 'Recovery & Readiness Score', 'Daily AI scores', 'Free', false),
      ('🧬', 'HRV + Sleep Analysis', 'Detailed stage breakdown', 'Free', false),
      ('🤖', 'AI Health Coach (Nepali)', 'Unlimited AI conversations', 'PRO ✦', true),
      ('🔮', 'Recovery Predictions', '3-day recovery forecast', 'PRO ✦', true),
      ('🧠', 'Burnout + Illness Detection', 'AI early warning system', 'PRO ✦', true),
      ('📖', 'Weekly Health Stories', 'AI-written narrative report', 'PRO ✦', true),
      ('☁️', 'Unlimited History', 'Full cloud backup', 'PRO ✦', true),
      ('👨‍👩‍👧', 'Family Sharing', 'Up to 5 members', 'Coming', true),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepBars(),
        const SizedBox(height: 24),
        Center(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [C.amberT(.15), const Color(0xFFFFD764).withValues(alpha: .08)]),
                border: Border.all(color: C.amberT(.3)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('✦', style: TextStyle(fontSize: 16, color: C.amber)),
                const SizedBox(width: 7),
                Text('PULSE AI PRO',
                    style: F.display(size: 13, weight: FontWeight.w700, color: C.amber, letterSpacing: .5)),
              ]),
            ),
            const SizedBox(height: 14),
            Text('Unlock your full\nhealth intelligence',
                textAlign: TextAlign.center,
                style: F.display(size: 27, weight: FontWeight.w700, color: C.textHi, letterSpacing: -.8, height: 1.2)),
            const SizedBox(height: 6),
            Text('तपाईंको AI companion को पूर्ण शक्ति अनुभव गर्नुहोस्',
                style: F.np(size: 14, color: C.dim5)),
          ]),
        ),
        const SizedBox(height: 20),
        // Plan toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: C.card,
            border: Border.all(color: C.whiteT(.07)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(children: [
            _plan('Monthly', 'NPR 499/mo', !annual, () => setState(() => annual = false)),
            _plan('Annual', 'NPR 3,999/yr', annual, () => setState(() => annual = true), badge: 'SAVE 33%'),
          ]),
        ),
        const SizedBox(height: 20),
        for (final f in feats)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: f.$5 ? C.amberT(.06) : C.accentT(.05),
              border: Border.all(color: f.$5 ? C.amberT(.2) : C.accentT(.12)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 26, height: 26, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: f.$5 ? C.amberT(.12) : C.accentT(.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(f.$1, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.$2,
                      style: F.body(
                          size: 13.5, weight: FontWeight.w700,
                          color: f.$4 == 'Coming' ? C.dim2 : C.textHi)),
                  const SizedBox(height: 2),
                  Text(f.$3, style: F.body(size: 12, color: C.dim6)),
                ]),
              ),
              Text(f.$4,
                  style: F.body(
                      size: 13, weight: FontWeight.w700,
                      color: f.$4 == 'PRO ✦' ? C.amber : (f.$4 == 'Coming' ? C.dim5 : C.dim7))),
            ]),
          ),
        const SizedBox(height: 14),
        _cta('Start 30-day free trial ✦', _next, sub: 'No credit card required', amber: true),
        _ghost('Continue with Free plan', _next),
      ]),
    );
  }

  Widget _plan(String label, String price, bool sel, VoidCallback onTap, {String? badge}) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Stack(clipBehavior: Clip.none, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                gradient: sel
                    ? LinearGradient(colors: [C.amberT(.15), C.amberT(.08)])
                    : null,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(children: [
                Text(label,
                    style: F.display(size: 13, weight: FontWeight.w700, color: sel ? C.amber : C.dim5)),
                const SizedBox(height: 1),
                Text(price,
                    style: F.body(size: 12, color: (sel ? C.amber : C.dim5).withValues(alpha: .7))),
              ]),
            ),
            if (badge != null)
              Positioned(
                top: -8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(20)),
                  child: Text(badge,
                      style: F.display(size: 9.5, weight: FontWeight.w700, color: const Color(0xFF03100A))),
                ),
              ),
          ]),
        ),
      );

  // ── 8. NOTIFICATIONS ───────────────────────────────────────────────────
  Widget _notifs() {
    final items = [
      ('💚', C.accent, '6:08 AM', 'Morning Brief Ready', 'Recovery 89 — आज Strength training का लागि उत्तम दिन।'),
      ('⚠️', C.amber, '3:42 PM', 'Stress Alert', 'Stress बढ्दैछ — ५ मिनेट breathing session गर्नुहोस्।'),
      ('😴', C.purple, '10:15 PM', 'Sleep Reminder', 'आज राति राम्रो निद्राले भोलि Recovery 92 हुनेछ।'),
      ('❤️', C.coral, '11:32 PM', 'High Heart Rate', 'Heart rate 102 bpm — आराम गर्नुहोस्।'),
      ('💧', C.blue, '2:00 PM', 'Hydration Reminder', 'पानी पिउनुस् — आज अझै १L बाँकी छ।'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepBars(),
        const SizedBox(height: 24),
        _kicker('STEP 6 OF 6'),
        const SizedBox(height: 6),
        _title('Stay in the loop'),
        const SizedBox(height: 4),
        _subNp('AI ले यस्ता notifications पठाउनेछ'),
        const SizedBox(height: 22),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 11),
            itemBuilder: (_, i) {
              final n = items[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: n.$2.withValues(alpha: .05),
                  border: Border.all(color: n.$2.withValues(alpha: .17)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 40, height: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: n.$2.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
                    child: Text(n.$1, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Pulse AI', style: F.display(size: 12, weight: FontWeight.w700, color: C.dim5)),
                        Text(n.$3, style: F.display(size: 11, color: C.dim8)),
                      ]),
                      const SizedBox(height: 4),
                      Text(n.$4, style: F.body(size: 14, weight: FontWeight.w700, color: n.$2)),
                      const SizedBox(height: 3),
                      Text(n.$5, style: F.np(size: 13, color: C.dim3, height: 1.4)),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _cta('Allow notifications', _next, sub: 'सूचनाहरू Allow गर्नुहोस्', subNp: true),
        _ghost('Not now', _next),
      ]),
    );
  }

  // ── 9. DONE ────────────────────────────────────────────────────────────
  Widget _done() {
    Widget stat(String v, Color c, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: C.card,
              border: Border.all(color: C.whiteT(.07)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Text(v, style: F.display(size: 24, weight: FontWeight.w700, color: c)),
              const SizedBox(height: 3),
              Text(label,
                  textAlign: TextAlign.center,
                  style: F.body(size: 11, weight: FontWeight.w600, color: C.dim5, height: 1.3)),
            ]),
          ),
        );
    return _fill(Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 120, height: 120,
          child: Stack(alignment: Alignment.center, children: [
            const _PulseRings(size: 120, color: C.accent),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [C.accent, Color(0xFF0CA86A)]),
                boxShadow: [BoxShadow(color: C.accentT(.4), blurRadius: 50)],
              ),
              child: const _PopIn(child: Icon(Icons.check, size: 36, color: Color(0xFF03100A))),
            ),
          ]),
        ),
        const SizedBox(height: 30),
        Text("You're all set!",
            style: F.display(size: 30, weight: FontWeight.w700, color: C.textHi, letterSpacing: -1.2)),
        const SizedBox(height: 6),
        Text('Pulse AI आफ्नो काम सुरु गर्यो ✦',
            style: F.np(size: 18, weight: FontWeight.w700, color: C.accent)),
        const SizedBox(height: 12),
        Text('तपाईंको AI health companion हरेक दिन\nतपाईंसँगै रहनेछ — data collect गर्छ,\nविश्लेषण गर्छ, र guidance दिन्छ।',
            textAlign: TextAlign.center, style: F.np(size: 16, color: C.dim5, height: 1.65)),
        const SizedBox(height: 40),
        Row(children: [
          stat('6', C.accent, 'Signals\ntracked'),
          const SizedBox(width: 10),
          stat('24/7', C.blue, 'Continuous\nmonitoring'),
          const SizedBox(width: 10),
          stat('AI', C.amber, 'Personal\ncoach'),
        ]),
        const SizedBox(height: 32),
        _cta('Open Pulse AI →',
            () => context.read<AppState>().completeOnboarding(name: _name.text),
            sub: 'Dashboard खोल्नुहोस्', subNp: true),
      ]),
    ));
  }
}

// ── animated helpers ──────────────────────────────────────────────────────

/// Expanding, fading concentric rings (the `pulseRing` keyframe).
class _PulseRings extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  const _PulseRings({required this.size, required this.color, this.opacity = .2});

  @override
  State<_PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<_PulseRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Stack(alignment: Alignment.center, children: [
        for (var i = 0; i < 3; i++) _ring(((_c.value + i / 3) % 1.0)),
      ]),
    );
  }

  Widget _ring(double t) {
    final scale = .7 + 1.5 * t;
    return Opacity(
      opacity: (widget.opacity * 4.5 * (1 - t)).clamp(0, 1).toDouble(),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.color, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Gentle scale throb (the `pulse` keyframe).
class _Throb extends StatefulWidget {
  final Widget child;
  const _Throb({required this.child});

  @override
  State<_Throb> createState() => _ThrobState();
}

class _ThrobState extends State<_Throb> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final s = 1 + .06 * math.sin(_c.value * 2 * math.pi);
        return Transform.scale(scale: s, child: child);
      },
      child: widget.child,
    );
  }
}

/// ECG-style heartbeat bars under the logo.
class _Heartbeat extends StatefulWidget {
  const _Heartbeat();

  @override
  State<_Heartbeat> createState() => _HeartbeatState();
}

class _HeartbeatState extends State<_Heartbeat> with SingleTickerProviderStateMixin {
  static const _heights = [4.0, 7, 5, 18, 9, 5, 22, 8, 6, 16, 7, 5];
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < _heights.length; i++) ...[
              _bar(i),
              if (i != _heights.length - 1) const SizedBox(width: 3),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bar(int i) {
    final h = _heights[i];
    final t = (_c.value + i * .08) % 1.0;
    final spike = t < .06 ? 2.0 : (t < .12 ? 1.4 : 1.0);
    return Container(
      width: 3,
      height: (h * spike).clamp(2, 28),
      decoration: BoxDecoration(
        color: C.accent.withValues(alpha: h > 15 ? 1 : (h > 9 ? .7 : .35)),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Elastic pop-in (the `checkin` keyframe on the done checkmark).
class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (_, v, c) => Transform.scale(scale: v, child: c),
      child: child,
    );
  }
}
