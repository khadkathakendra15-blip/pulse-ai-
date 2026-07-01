import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Connection lifecycle, mirrors the SDKs' own states
/// (Android: `BleOperateManager`; iOS: `QCCentralManager.QCState`).
enum BandState { unknown, idle, scanning, connecting, connected, disconnected }

class BandDevice {
  final String name;
  final String mac;
  final int rssi;
  const BandDevice(this.name, this.mac, this.rssi);

  factory BandDevice.fromMap(Map m) =>
      BandDevice((m['name'] ?? '') as String, (m['mac'] ?? '') as String, (m['rssi'] ?? 0) as int);
}

/// Snapshot of the latest health metrics read from the ring/band. Fields are
/// nullable — a given device/firmware may not support all of them.
class BandVitals {
  final int? heartRate; // bpm
  final int? hrv; // ms
  final int? spo2; // %
  final int? steps;
  final int? battery; // %
  final int? stress;
  final int? sleepMinutes;
  const BandVitals({
    this.heartRate,
    this.hrv,
    this.spo2,
    this.steps,
    this.battery,
    this.stress,
    this.sleepMinutes,
  });

  factory BandVitals.fromMap(Map m) => BandVitals(
        heartRate: m['heartRate'] as int?,
        hrv: m['hrv'] as int?,
        spo2: m['spo2'] as int?,
        steps: m['steps'] as int?,
        battery: m['battery'] as int?,
        stress: m['stress'] as int?,
        sleepMinutes: m['sleepMinutes'] as int?,
      );
}

/// Dart side of the platform bridge to the native wearable SDKs.
///
/// Native handlers must be registered on the same channel names:
///   - Android: `MethodChannel("pulse_ai/band")` driving the QRing AAR
///     (`com.oudmon.ble.*` — `BleScannerHelper`, `BleOperateManager`,
///     `CommandHandle.executeReqCmd`).
///   - iOS: `FlutterMethodChannel name:@"pulse_ai/band"` driving QCBandSDK
///     (`QCCentralManager`, `QCSDKManager`, `QCSDKCmdCreator`).
///
/// See `README.md` → "Native SDK wiring" for the handler templates. Until the
/// native side exists, every call throws `MissingPluginException`, which the
/// repository swallows so the UI falls back to demo data.
class BandBridge {
  BandBridge._();
  static final BandBridge instance = BandBridge._();

  static const _method = MethodChannel('pulse_ai/band');
  static const _scanEvents = EventChannel('pulse_ai/band/scan');
  static const _stateEvents = EventChannel('pulse_ai/band/state');
  static const _vitalsEvents = EventChannel('pulse_ai/band/vitals');

  Stream<List<BandDevice>>? _scan;
  Stream<BandState>? _state;
  Stream<BandVitals>? _vitals;

  Stream<List<BandDevice>> get scanResults => _scan ??= _scanEvents
      .receiveBroadcastStream()
      .map((e) => (e as List).map((d) => BandDevice.fromMap(d as Map)).toList());

  Stream<BandState> get connectionState => _state ??= _stateEvents
      .receiveBroadcastStream()
      .map((e) => BandState.values[(e as int).clamp(0, BandState.values.length - 1)]);

  Stream<BandVitals> get liveVitals =>
      _vitals ??= _vitalsEvents.receiveBroadcastStream().map((e) => BandVitals.fromMap(e as Map));

  Future<void> startScan({int timeoutSeconds = 30}) =>
      _invoke('startScan', {'timeout': timeoutSeconds});
  Future<void> stopScan() => _invoke('stopScan');
  Future<void> connect(String mac) => _invoke('connect', {'mac': mac});
  Future<void> disconnect() => _invoke('disconnect');

  /// One-shot fetch of the most recent stored metrics.
  Future<BandVitals> latestVitals() async {
    final m = await _method.invokeMethod<Map>('latestVitals');
    return m == null ? const BandVitals() : BandVitals.fromMap(m);
  }

  Future<bool> get isConnected async =>
      (await _method.invokeMethod<bool>('isConnected')) ?? false;

  Future<void> _invoke(String name, [Map<String, dynamic>? args]) async {
    try {
      await _method.invokeMethod(name, args);
    } on MissingPluginException {
      // Native SDK not wired yet — caller treats this as "no band".
      if (kDebugMode) debugPrint('[BandBridge] native handler missing for "$name"');
      rethrow;
    }
  }
}
