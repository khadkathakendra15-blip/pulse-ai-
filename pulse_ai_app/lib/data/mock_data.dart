import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'models.dart';

/// Faithful Dart port of the mockup's `renderVals()` — every string, number,
/// colour and ordering matches `Pulse AI App - Standalone`. Bilingual: pass
/// [np] = true for Nepali, false for English.
///
/// This is the demo/preview data source. The live data source
/// (`SdkHealthRepository`) produces the same shape from the QRing / QWatchPro
/// band, so screens never need to know which one they're rendering.
class PulseData {
  final bool np;
  final String name;
  final Color accent;

  PulseData({required this.np, this.name = 'Thakendra', this.accent = C.accent});

  static const Color _off = C.dim7;

  // ── trend-bar helper (mirrors mkBars in the mockup) ──────────────────────
  static List<Bar> _bars(List<int> vals, Color base) => [
        for (var i = 0; i < vals.length; i++)
          Bar(
            vals[i].toDouble(),
            base.withValues(alpha: i >= 5 ? 0.95 : (i >= 3 ? 0.5 : 0.22)),
          ),
      ];

  // ── Vitals (Sleep, HRV, Stress, Heart, SpO2, Activity) ───────────────────
  List<Vital> get vitals => [
        Vital(
          label: 'SLEEP', value: '8h 12m', unit: '', color: C.purple,
          delta: '+42m', deltaColor: accent, arrow: '↑', avg: '7h 28m',
          baseline: '7h 30m', conf: 96,
          interp: np ? 'Deep sleep +12% — recovery ↑ 8%' : 'Deep sleep up 12% — drove recovery improvement',
          bars: _bars([45, 50, 55, 40, 60, 72, 90], C.purple),
        ),
        Vital(
          label: 'HRV', value: '68', unit: 'ms', color: accent,
          delta: '+6ms', deltaColor: accent, arrow: '↑', avg: '62ms',
          baseline: '60ms', conf: 91,
          interp: np ? 'Nervous system fully recovered — peak condition' : 'Nervous system fully recovered — ideal for training',
          bars: _bars([50, 55, 45, 52, 62, 70, 88], accent),
        ),
        Vital(
          label: 'STRESS', value: 'Low', unit: '', color: C.amber,
          delta: '−12%', deltaColor: accent, arrow: '↓', avg: 'Medium',
          baseline: 'Medium', conf: 87,
          interp: np ? 'Stress कम — हिजोको breathing session ले मदद गर्यो' : "Stress lowered — yesterday's breathing session helped",
          bars: _bars([80, 72, 85, 75, 65, 58, 40], C.amber),
        ),
        Vital(
          label: 'HEART', value: '58', unit: 'bpm', color: C.coral,
          delta: '−3', deltaColor: accent, arrow: '↓', avg: '61bpm',
          baseline: '62bpm', conf: 94,
          interp: np ? 'Resting HR 6 महिनाको सबैभन्दा कम — cardiac health ↑' : 'Resting HR at 6-month low — excellent cardiac health',
          bars: _bars([75, 70, 78, 72, 68, 64, 58], C.coral),
        ),
        Vital(
          label: 'BLOOD O₂', value: '98', unit: '%', color: C.blue,
          delta: 'stable', deltaColor: _off, arrow: '·', avg: '98%',
          baseline: '97%', conf: 98,
          interp: np ? 'Optimal oxygen — lungs राम्ररी काम गरिरहेका छन्' : 'Optimal oxygen saturation — lungs performing well',
          bars: _bars([88, 90, 88, 92, 90, 92, 98], C.blue),
        ),
        Vital(
          label: 'ACTIVITY', value: '8,400', unit: '', color: accent,
          delta: '+2.1k', deltaColor: accent, arrow: '↑', avg: '6,300',
          baseline: '6,000', conf: 99,
          interp: np ? 'Weekly average भन्दा 2,100 steps बढी — active day!' : 'Active day — 2,100 steps above your weekly average',
          bars: _bars([55, 48, 65, 52, 70, 78, 90], accent),
        ),
      ];

  // ── AI Mission ───────────────────────────────────────────────────────────
  List<Mission> get mission => [
        Mission(
          np ? '🏃 ३० मिनेट jog गर्नुहोस्' : '🏃 Light jog 30 min',
          np ? 'Recovery ८९ — आज exercise का लागि उत्तम' : 'Recovery 89 — ideal day for exercise',
          np ? 'गरियो ✓' : 'Done ✓', true,
        ),
        Mission(
          np ? '💧 २.५L पानी पिउनुहोस्' : '💧 Drink 2.5L water',
          np ? 'हिजो stress बढी थियो — hydration महत्त्वपूर्ण' : 'Stress was elevated yesterday — hydrate well',
          '1.2L', false,
        ),
        Mission(
          np ? '😴 १०:३० अघि सुत्नुहोस्' : '😴 Sleep before 10:30 PM',
          np ? '७-दिन streak कायम राख्नुहोस्' : 'Protect your 7-day sleep streak',
          '—', false,
        ),
      ];

  // ── Health-score breakdown ────────────────────────────────────────────────
  List<ScoreComponent> get scoreComponents => [
        ScoreComponent(label: 'Sleep', detail: '8h 12m · Deep: 1h 52m', score: 95, color: C.purple, dval: '↑ +8', dcolor: accent, conf: 96, baseline: 88),
        ScoreComponent(label: 'HRV', detail: '68ms overnight average', score: 88, color: accent, dval: '↑ +6', dcolor: accent, conf: 91, baseline: 62),
        ScoreComponent(label: 'Heart Health', detail: '58 bpm resting heart rate', score: 94, color: C.coral, dval: '↑ +2', dcolor: accent, conf: 94, baseline: 90),
        ScoreComponent(label: 'Stress', detail: 'Low · 5 of 7 days calm', score: 82, color: C.amber, dval: '↓ −3', dcolor: _off, conf: 87, baseline: 75),
        ScoreComponent(label: 'Activity', detail: '8,400 steps · 42 active min', score: 79, color: C.purpleSoft, dval: '↑ +12', dcolor: accent, conf: 99, baseline: 72),
        ScoreComponent(label: 'Recovery', detail: '7-day average: 81', score: 89, color: accent, dval: '↑ +4', dcolor: accent, conf: 93, baseline: 81),
      ];

  // ── Energy forecast slots ─────────────────────────────────────────────────
  List<EnergySlot> get energySlots => [
        EnergySlot('6 AM – 8 AM', np ? '🌅 जागरण — हल्का movement, stretch' : '🌅 Wake & light movement', 72, C.amber),
        EnergySlot('8 AM – 12 PM', np ? '🧠 Peak — गहिरो काम, creative tasks' : '🧠 Peak zone — deep work & creative tasks', 95, accent),
        EnergySlot('12 PM – 2 PM', np ? '☀️ Good — meeting, हल्का काम' : '☀️ Good — meetings & light tasks', 78, C.blue),
        EnergySlot('2 PM – 4 PM', np ? '🌙 Dip — आराम वा हल्का walk' : '🌙 Dip — rest or a light walk', 43, C.coral),
        EnergySlot('4 PM – 6 PM', np ? '🏋️ Good — exercise, सामाजिक' : '🏋️ Good — exercise & social time', 68, C.amber),
        EnergySlot('6 PM – 10 PM', np ? '🌙 Wind down — आराम, निद्राको तयारी' : '🌙 Wind down — relax & prep for sleep', 35, C.purple),
      ];

  // ── 30-day health calendar heat-map ───────────────────────────────────────
  List<CalDay> get calendar {
    const pat = 'GGGGGFGGGGRGGGGFGGGGGGFGGGRGGG';
    const map = {
      'G': [Color(0xD12BE3A0), Color(0xFF03100A)],
      'F': [Color(0xD1F5B342), Color(0xFF161200)],
      'R': [Color(0xC7FF6B72), Color(0xFF160608)],
    };
    return [
      for (var i = 0; i < pat.length; i++)
        CalDay(i + 1, map[pat[i]]![0], map[pat[i]]![1]),
    ];
  }

  List<Highlight> get monthlyHighlights => [
        Highlight('😴', C.purpleT(.12), 'Best Sleep Month', np ? 'जुन — औसत ७घ ४८म प्रति रात' : 'June — avg 7h 48m per night', '7h 48m', C.purple),
        Highlight('🧬', C.accentT(.12), 'HRV Baseline Improved', np ? '५४ms → ६८ms, ३० दिनमा' : '54ms → 68ms over 30 days', '+26%', accent),
        Highlight('🔥', C.amberT(.12), 'Recovery Streak', np ? '१२ दिन लगातार ७५+ Recovery' : '12 consecutive days above 75', '12d', C.amber),
        Highlight('📉', C.accentT(.12), np ? 'Stress कम भयो' : 'Stress Reduced', np ? 'गत महिनाको तुलनामा ३०% कम' : '30% lower vs last month', '−30%', accent),
      ];

  List<Achievement> get achievements => [
        Achievement(
          icon: '🔥', title: np ? '७-दिन Recovery Streak' : '7-Day Recovery Streak',
          desc: np ? 'लगातार ७ दिन Recovery ८०+ — तपाईं consistent हुनुहुन्छ!' : 'Recovery above 80 for 7 straight days — remarkable!',
          bg: const Color(0xFF13100D), border: C.amberT(.22), iconBg: C.amberT(.12), titleColor: C.textHi,
          badge: 'UNLOCKED', badgeColor: C.amber, badgeBg: C.amberT(.15),
        ),
        Achievement(
          icon: '😴', title: np ? '३०-दिन Sleep Champion' : '30-Day Sleep Champion',
          desc: np ? '३० दिन ७+ घण्टा निद्रा — तपाईंको सबैभन्दा ठूलो उपलब्धि!' : '30 consecutive nights of 7+ hours sleep!',
          bg: const Color(0xFF0D1019), border: C.purpleT(.22), iconBg: C.purpleT(.12), titleColor: C.textHi,
          badge: 'UNLOCKED', badgeColor: C.purple, badgeBg: C.purpleT(.15),
        ),
        Achievement(
          icon: '🏆', title: np ? 'Recovery ९०+ पुग्नुहोस्' : 'Reach Recovery 90+',
          desc: np ? 'एक राम्रो रात पछि तपाईं यहाँ पुग्नुहुन्छ — ८९ सम्म पुगिसक्यो!' : 'One great sleep away — currently at 89!',
          bg: const Color(0xFF0F1318), border: C.whiteT(.07), iconBg: C.whiteT(.06), titleColor: const Color(0xFF8C949B),
          badge: '89 / 90', badgeColor: accent, badgeBg: C.accentT(.12),
        ),
      ];

  List<FutureMod> get futureMods => [
        FutureMod('🥗', 'Nutrition AI', np ? 'खाना र nutrition tracking' : 'Food & nutrition AI tracking', accent),
        FutureMod('🧠', 'Mental Wellness', np ? 'Mood, anxiety र mindfulness' : 'Mood, anxiety & mindfulness', C.purple),
        FutureMod('👨‍👩‍👧', 'Family Health', np ? 'परिवारको health एकैठाउँ' : "Your whole family's health", C.blue),
        FutureMod('🏢', 'Corporate Wellness', np ? 'Team health र productivity' : 'Team health & productivity', C.amber),
        FutureMod('👨‍⚕️', 'Doctor Reports', np ? 'Doctor सँग data share गर्नुस्' : 'Share insights with doctors', C.coral),
        FutureMod('🔬', 'Lab Results', np ? 'Lab test र health markers' : 'Lab tests & health markers', C.purpleSoft),
      ];

  List<QuickPrompt> get quicks => [
        QuickPrompt(np ? 'Recovery किन कम छ?' : 'Why low recovery?', 'recovery', 'Recovery किन कम छ?', 'Why is my recovery low?'),
        QuickPrompt(np ? 'आजको योजना बनाउनुहोस्' : 'Plan my day', 'plan', 'आजको योजना', 'Plan my day'),
        QuickPrompt(np ? 'के workout गर्न सकिन्छ?' : 'Can I work out?', 'workout', 'के आज workout गर्नु ठीक छ?', 'Should I work out today?'),
      ];

  // ── Coach: opening conversation ────────────────────────────────────────────
  List<ChatMessage> baseMessages() => [
        ChatMessage.aiText(np
            ? 'नमस्ते ठाकेन्द्र! आज Recovery ८९ र Readiness ८४ छ — राम्रो निद्रा, उच्च HRV र कम resting HR को कारण। Strength training का लागि उत्तम दिन। तपाईंको शरीर आज पूर्णतः तयार छ। 💪'
            : 'Hi Thakendra! Recovery 89, Readiness 84 today — driven by excellent sleep, high HRV and low resting HR. Your body is primed for strength training. Make the most of today. 💪'),
        ChatMessage.user(np ? 'म किन थकित महसुस गर्दैछु?' : 'Why do I feel tired?'),
        ChatMessage.analysis(
          title: np ? 'AI ले ३ कारण भेट्यो' : 'AI found 3 causes',
          chips: [
            AnalysisChip('Sleep last night', '5h 02m', '↓', C.coral),
            AnalysisChip('Afternoon stress', 'High', '↑', C.coral),
            AnalysisChip('HRV overnight', '42 ms', '↓', C.coral),
          ],
          rec: np ? 'आज राति १०:३० अघि सुत्नुहोस् र बिहान २० मिनेट हल्का walk गर्नुहोस्।' : 'Sleep before 10:30 PM tonight and take a 20-min light walk in the morning.',
          conf: 88,
          outcome: np ? 'यो गर्नुभयो भने भोलि Recovery ~८६ र Energy राम्रो हुन्छ।' : "Follow this and tomorrow's recovery should reach ~86 with improved energy.",
        ),
      ];

  /// Canned coach replies keyed by quick-prompt. Mirrors `cannedReply`.
  ChatMessage cannedReply(String key) {
    switch (key) {
      case 'recovery':
        return ChatMessage.analysis(
          title: np ? 'Recovery कम भएको कारण' : 'Why your recovery dropped',
          chips: [
            AnalysisChip('Deep sleep', '38 min', '↓', C.coral),
            AnalysisChip('Resting HR', '64 bpm', '↑', C.coral),
            AnalysisChip('Stress load', 'Elevated', '↑', C.coral),
          ],
          rec: np ? 'आज हल्का गतिविधि गर्नुहोस्। ५ मिनेट breathing session गर्नुहोस्।' : 'Keep today light. Try a 5-min breathing session and sleep on time tonight.',
          conf: 92,
          outcome: np ? 'भोलि Recovery ७५–८०+ हुन सक्छ यदि आज समयमा सुत्नुभयो।' : 'Recovery could reach 75–80+ tomorrow if you sleep on time tonight.',
        );
      case 'plan':
        return ChatMessage.aiText(np
            ? 'आजको स्वास्थ्य योजना ☀️\n\n• बिहान: Strength training (Recovery ८९)\n• दिउँसो: २.५L पानी पिउनुहोस्\n• साँझ: १०:१५ अघि सुत्ने तयारी\n• रातको दिनचर्या: ५ मिनेट breathing'
            : "Today's plan ☀️\n\n• Morning: Strength training (recovery 89)\n• Midday: Drink 2.5L water\n• Evening: Wind down before 10:15 PM\n• Night: 5-min breathing session");
      case 'workout':
      default:
        return ChatMessage.analysis(
          title: np ? 'आज workout गर्न सकिन्छ' : 'Yes — your body is ready',
          chips: [
            AnalysisChip('Recovery score', '89/100', '↑', C.blue),
            AnalysisChip('Readiness', '84/100', '↑', C.blue),
            AnalysisChip('HRV', '68ms ↑', '↑', C.blue),
          ],
          rec: np ? 'Strength training वा HIIT उत्तम। राम्ररी warm-up र cool-down गर्नुहोस्।' : "Strength or HIIT is ideal. Warm up well and don't skip your cool-down.",
          conf: 96,
          outcome: np ? 'आजको workout पछि recovery score कायम रहन सक्छ — राम्रो निद्रागरे।' : 'Recovery should hold strong post-workout if you sleep well tonight.',
        );
    }
  }

  // ── Long-form bilingual strings ────────────────────────────────────────────
  String get heroCaption => np
      ? 'आज तपाईं अत्यन्त राम्रो अवस्थामा हुनुहुन्छ — भारी workout गर्न उत्तम दिन।'
      : 'You are in excellent condition today — a perfect day for an intense workout.';

  String get morningBriefMain => np
      ? 'शुभ प्रभात ठाकेन्द्र! हिजोको तुलनामा तपाईंको Recovery ८% ले बढेको छ। राति ८ घण्टा १२ मिनेट सुत्नुभयो र REM phase सामान्यभन्दा अगाडि आयो — तपाईंको nervous system राम्ररी recover भएको संकेत हो। Stress कम छ, HRV यो हप्ताको उच्चतम बिन्दुमा पुगेको छ। यो महिनाका तपाईंका उत्तम दिनमध्ये एक हो।'
      : "Good morning, Thakendra. Your recovery has improved 8% since yesterday. Last night's 8h 12m included an earlier-than-usual REM cycle — a clear sign your nervous system is thriving. Stress is low and HRV has hit this week's peak. Today is one of your top 5 recovery days this month.";

  String get morningBriefAction => np
      ? 'तपाईंको शरीर आज कठिन workout का लागि पूर्णतः तयार छ। 💪'
      : 'Your body is completely ready for a demanding workout today. 💪';

  String get morningBriefEng => np
      ? "Good morning! 8h 12m deep sleep, HRV at 68ms — week's best. One of your top recovery days this month."
      : '';

  String get tmrCaption => np ? 'आज राम्रो निद्राले यो संभव छ' : 'Achievable with good sleep tonight';
  String get missionSubtitle => np ? 'तपाईंको आजको अवस्था अनुसार AI ले बनाएको लक्ष्यहरू' : 'AI-personalized goals based on your current condition';

  String get whyCardTitle => np ? 'Recovery ८९ किन भयो?' : 'Why is my Recovery 89?';
  String get whyCardSub => np ? 'AI ले कारण, भविष्यवाणी र सुझाव दिन्छ' : "AI explains what happened, why, what's next & what to do";
  String get whyWhat => np ? 'Recovery ८% ↑ भयो' : 'Recovery up 8% vs yesterday';
  String get whyWhy => np ? 'Deep sleep + उच्च HRV' : 'Deep sleep + high HRV';
  String get whyNext => np ? 'भोलि: ९२ predicted' : 'Tomorrow: 92 predicted';
  String get whyTodo => np ? 'Strength training गर्नुहोस्' : 'Strength train today';
  String get whyConclusion => np
      ? 'राम्रो निद्रा, उच्च HRV र कम resting heart rate — यी तीन कारणले तपाईंको Recovery उच्च छ। यही routine कायम राख्नुहोस्।'
      : 'Deep sleep, high HRV and low resting HR combined to boost your recovery. Keep this routine going.';
  String get factor1Label => np ? 'निद्राको गुणस्तर' : 'Sleep quality';
  String get factor2Label => np ? 'HRV (overnight)' : 'HRV overnight';
  String get factor3Label => np ? 'Resting Heart Rate' : 'Resting heart rate';

  String get scoreCaption => np ? 'तपाईंको स्वास्थ्य उत्कृष्ट अवस्थामा छ ✦' : 'Your health is in excellent condition ✦';
  String get whyScoreTitle => np ? '९२ कसरी calculate भयो?' : 'How is 92 calculated?';
  String get whyScoreSub => np ? 'AI ले score बनाउने तरिका हेर्नुहोस्' : 'See exactly how your score is built';
  String get whyScoreText => np
      ? 'प्रत्येक signal लाई AI ले weighing गर्छ: Sleep (३०%), HRV (२५%), Heart Health (२०%), Stress (१०%), Activity (१०%), Recovery (५%)। यी सबैलाई तपाईंको personal baseline सँग compare गरेर score बनाइन्छ। Weights तपाईंको goals अनुसार adjust हुन्छन्।'
      : 'Each signal is weighted: Sleep (30%) + HRV (25%) + Heart (20%) + Stress (10%) + Activity (10%) + Recovery (5%). Each is compared to your personal baseline, then combined. Weights adapt to your health goals over time.';

  String get weeklyStory => np
      ? 'यो हप्ता तपाईंको स्वास्थ्यमा उल्लेखनीय सुधार देखियो। औसत निद्रा ७ घण्टा ४८ मिनेट रह्यो — गत हप्ताभन्दा ४२ मिनेट बढी। HRV ५४ms बाट ६८ms मा पुग्यो — यो तपाईंको nervous system पूर्णतः recover भएको प्रमाण हो। ७ दिनमध्ये ५ दिन stress कम रह्यो। Recovery average ७२ बाट ८२ मा पुग्यो।'
      : 'This was your healthiest week in the past month. Sleep averaged 7h 48m — 42 minutes more than last week. HRV climbed from 54ms to 68ms, clear evidence your nervous system is fully recovering. Stress stayed low on 5 of 7 days. Recovery average rose from 72 to 82.';
  String get weeklyConclusion => np
      ? 'बधाई छ! यो trend कायम राख्नुस् — अर्को हप्ता Health Score ९५+ पुग्ने संभावना छ। 🎉'
      : 'Congratulations — keep this going and you could hit Health Score 95+ next week. 🎉';

  String get burnoutRec => np
      ? 'यो हप्ता आराम बढाउनुहोस्। २ दिन हल्का गतिविधि गर्नुहोस् र हर रात १०:३० अघि सुत्ने कोशिश गर्नुहोस्।'
      : 'Build in more rest this week. Keep 2 days light and try to sleep before 10:30 PM every night.';
  String get bodyAgeCaption => np ? 'वास्तविक उमेरभन्दा २.२ वर्ष कम ✦' : '2.2 years younger than your actual age ✦';
  String get ecosystemSub => np ? 'Pulse AI को अर्को chapter — आउँदैछ' : 'The next chapter of Pulse AI — coming soon';
  String get inputPlaceholder => np ? 'Pulse Coach लाई सोध्नुहोस्…' : 'Ask Pulse Coach…';

  String get greeting => np ? 'नमस्ते, $name 👋' : 'Hi, $name 👋';
}
