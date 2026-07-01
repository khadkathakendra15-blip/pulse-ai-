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

  PulseData get data => PulseData(np: nepali);
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
  void ask(QuickPrompt q) {
    final d = data;
    final current = _messages ?? d.baseMessages();
    _messages = [
      ...current,
      ChatMessage.user(nepali ? q.npQuestion : q.enQuestion),
      d.cannedReply(q.cannedKey),
    ];
    notifyListeners();
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
