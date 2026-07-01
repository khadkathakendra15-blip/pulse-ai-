/*
 * iOS native bridge for the Pulse AI Flutter app → QCBandSDK (QWatchPro).
 *
 * SETUP
 * 1. Ask the vendor for an `.xcframework` (the shipped `QCBandSDK.framework`
 *    is a static framework; verify arm64-simulator support with
 *    `lipo -archs`). Add it to the Runner target (Embed & Sign).
 * 2. Add a PrivacyInfo.xcprivacy + Info.plist keys:
 *        NSBluetoothAlwaysUsageDescription
 *        UIBackgroundModes → bluetooth-central
 * 3. Register from AppDelegate.application(_:didFinishLaunchingWithOptions:):
 *        BandPlugin.register(with: controller.binaryMessenger)
 *
 * Channel names MUST match `lib/data/band_channel.dart`.
 *
 * NOTE: QCSDKCmdCreator requires commands to be issued *sequentially* — wrap
 * calls in a serial queue / chain the completion blocks; concurrent calls fail.
 */
import Flutter
import CoreBluetooth
import QCBandSDK

final class BandPlugin: NSObject {
    private var scanSink: FlutterEventSink?
    private var stateSink: FlutterEventSink?
    private var vitalsSink: FlutterEventSink?

    static func register(with messenger: FlutterBinaryMessenger) {
        let plugin = BandPlugin()
        FlutterMethodChannel(name: "pulse_ai/band", binaryMessenger: messenger)
            .setMethodCallHandler(plugin.handle)
        FlutterEventChannel(name: "pulse_ai/band/scan", binaryMessenger: messenger)
            .setStreamHandler(StreamProxy { plugin.scanSink = $0 })
        FlutterEventChannel(name: "pulse_ai/band/state", binaryMessenger: messenger)
            .setStreamHandler(StreamProxy { plugin.stateSink = $0 })
        FlutterEventChannel(name: "pulse_ai/band/vitals", binaryMessenger: messenger)
            .setStreamHandler(StreamProxy { plugin.vitalsSink = $0 })
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScan":
            QCCentralManager.shared().scan()            // implement QCCentralManagerDelegate → scanSink
            result(nil)
        case "stopScan":
            QCCentralManager.shared().stopScan()
            result(nil)
        case "connect":
            // resolve CBPeripheral from the scan cache by mac, then:
            // QCCentralManager.shared().connect(peripheral)
            // on connect: QCSDKManager.shareInstance().addPeripheral(peripheral) { ok in ... }
            result(nil)
        case "disconnect":
            QCCentralManager.shared().remove()
            result(nil)
        case "isConnected":
            result(QCCentralManager.shared().deviceState == .connected)
        case "latestVitals":
            // Chain QCSDKCmdCreator reads (battery, HR, steps, sleep…) on a serial
            // queue and assemble the BandVitals map, then result(map).
            result(["heartRate": NSNull(), "hrv": NSNull(), "spo2": NSNull(),
                    "steps": NSNull(), "battery": NSNull(), "stress": NSNull(),
                    "sleepMinutes": NSNull()])
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

/// Minimal reusable FlutterStreamHandler that just forwards the sink.
private final class StreamProxy: NSObject, FlutterStreamHandler {
    private let onSink: (FlutterEventSink?) -> Void
    init(_ onSink: @escaping (FlutterEventSink?) -> Void) { self.onSink = onSink }
    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onSink(events); return nil
    }
    func onCancel(withArguments _: Any?) -> FlutterError? { onSink(nil); return nil }
}
