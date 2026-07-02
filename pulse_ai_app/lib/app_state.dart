import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'data/band_channel.dart';
import 'data/mock_data.dart';
import 'data/models.dart';

enum PulseTab { home, coach, score, insights, body }

/// Single source of truth for the app — a direct analogue of the mockup's
/// `Component extends DCLogic` state machine, plus live-band wiring.
class AppState extends ChangeNotifier {
  PulseTab tab = PulseTab.home;
  bool nepali = true; // mockup defaults to 'np'
  bool whyOpen = false;
  bool whyScoreOpen = false;
  bool coachTyping = false; // simulated "typing…" indicator

  /// Onboarding gate — app starts on the onboarding flow, then the shell.
  bool onboardingDone = false;
  String userName = 'Thakendra';

  void completeOnboarding({String? name}) {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) userName = n;
    onboardingDone = true;
    notifyListeners();
  }

  /// Coach conversation. Null means "show the opening script".
  List<ChatMessage>? _messages;

  // Band status (drives the "Band Live" pill + future live metrics).
  BandState bandState = BandState.unknown;
  BandVitals? liveVitals;
  StreamSubscription? _stateSub;
  StreamSubscription? _vitalsSub;

  AppState({bool startNepali = true}) {
    nepali = startNepali;
    _bindBand();
  }

  PulseData get data => PulseData(np: nepali, name: userName);
  bool get bandLive => bandState == BandState.connected;

  List<ChatMessage> get messages => _messages ?? data.baseMessages();

  // ── navigation ────────────────────────────────────────────────────────────
  void go(PulseTab t) {
    if (tab == t) return;
    tab = t;
    notifyListeners();
  }

  // ── language ──────────────────────────────────────────────────────────────
  void setNepali(bool v) {
    if (nepali == v) return;
    nepali = v;
    // Reset any in-progress conversation so it re-renders in the new language.
    _messages = null;
    notifyListeners();
  }

  // ── expandable cards ────────────────────────────────────────────────────────
  void toggleWhy() {
    whyOpen = !whyOpen;
    notifyListeners();
  }

  void toggleWhyScore() {
    whyScoreOpen = !whyScoreOpen;
    notifyListeners();
  }

  // ── coach ───────────────────────────────────────────────────────────────────
  /// Quick-prompt chip → user bubble, then the matching canned analysis.
  void ask(QuickPrompt q) {
    _appendUser(nepali ? q.npQuestion : q.enQuestion);
    _replyAfterDelay(() => data.cannedReply(q.cannedKey));
  }

  /// Free-typed message → user bubble, then a simulated bilingual reply.
  void sendMessage(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _appendUser(t);
    _replyAfterDelay(() => data.dummyReply(t));
  }

  void _appendUser(String text) {
    final current = _messages ?? data.baseMessages();
    _messages = [...current, ChatMessage.user(text)];
    coachTyping = true;
    notifyListeners();
  }

  void _replyAfterDelay(ChatMessage Function() build) {
    Future.delayed(const Duration(milliseconds: 750), () {
      final current = _messages ?? data.baseMessages();
      _messages = [...current, build()];
      coachTyping = false;
      notifyListeners();
    });
  }

  // ── band lifecycle ──────────────────────────────────────────────────────────
  void _bindBand() {
    try {
      _stateSub = BandBridge.instance.connectionState.listen((s) {
        bandState = s;
        notifyListeners();
      }, onError: (_) {});
      _vitalsSub = BandBridge.instance.liveVitals.listen((v) {
        liveVitals = v;
        notifyListeners();
      }, onError: (_) {});
    } on MissingPluginException {
      // Native SDK not present — stay in demo mode.
    }
  }

  Future<void> connectBand(String mac) async {
    try {
      await BandBridge.instance.connect(mac);
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('connectBand failed: $e');
    } on MissingPluginException {
      if (kDebugMode) debugPrint('Band SDK not wired — running in demo mode.');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _vitalsSub?.cancel();
    super.dispose();
  }
}
