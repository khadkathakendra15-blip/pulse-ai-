/*
 * Android native bridge for the Pulse AI Flutter app → QRing SDK (oudmon AAR).
 *
 * SETUP
 * 1. Copy `qring_sdk_1.0.0.27.aar` into `android/app/libs/`.
 * 2. In `android/app/build.gradle`:
 *        repositories { flatDir { dirs 'libs' } }
 *        dependencies { implementation(name: 'qring_sdk_1.0.0.27', ext: 'aar') }
 *    (Also add the SDK's transitive deps it expects — see the sample app's
 *     build.gradle: okhttp, mmkv, etc. Only those the SDK actually requires.)
 * 3. Merge the BLE permissions from the sample `AndroidManifest.xml`
 *    (BLUETOOTH_SCAN/CONNECT, ACCESS_FINE_LOCATION, …) — request only what
 *    Pulse AI uses; drop SMS / call-log / MANAGE_EXTERNAL_STORAGE.
 * 4. Register this plugin from MainActivity.configureFlutterEngine():
 *        BandPlugin(this).register(flutterEngine.dartExecutor.binaryMessenger)
 *
 * The method/event channel names MUST match `lib/data/band_channel.dart`.
 */
package com.pulseai.app

import android.content.Context
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger

import com.oudmon.ble.base.bluetooth.BleOperateManager
import com.oudmon.ble.base.scan.BleScannerHelper
import com.oudmon.ble.base.scan.ScanWrapperCallback
import com.oudmon.ble.base.communication.CommandHandle
// import the concrete request/response classes you need, e.g. battery, HR, steps.

class BandPlugin(private val context: Context) {

    private var scanSink: EventChannel.EventSink? = null
    private var stateSink: EventChannel.EventSink? = null
    private var vitalsSink: EventChannel.EventSink? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "pulse_ai/band").setMethodCallHandler { call, result ->
            when (call.method) {
                "startScan" -> { startScan(); result.success(null) }
                "stopScan" -> { BleScannerHelper.getInstance().stopScan(context); result.success(null) }
                "connect" -> {
                    val mac = call.argument<String>("mac")!!
                    BleOperateManager.getInstance().connectDirectly(mac)
                    result.success(null)
                }
                "disconnect" -> { BleOperateManager.getInstance().disconnect(); result.success(null) }
                "isConnected" -> result.success(BleOperateManager.getInstance().isConnected)
                "latestVitals" -> result.success(readLatestVitals())
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "pulse_ai/band/scan").setStreamHandler(sink(::scanSink))
        EventChannel(messenger, "pulse_ai/band/state").setStreamHandler(sink(::stateSink))
        EventChannel(messenger, "pulse_ai/band/vitals").setStreamHandler(sink(::vitalsSink))
    }

    private fun startScan() {
        BleScannerHelper.getInstance().scanDevice(context, null, object : ScanWrapperCallback {
            override fun onLeScan(device: android.bluetooth.BluetoothDevice?, rssi: Int, record: ByteArray?) {
                device ?: return
                scanSink?.success(listOf(mapOf("name" to (device.name ?: ""), "mac" to device.address, "rssi" to rssi)))
            }
            override fun onStart() {}
            override fun onStop() {}
            override fun onScanFailed(errorCode: Int) {}
            override fun onParsedData(d: android.bluetooth.BluetoothDevice?, r: com.oudmon.ble.base.scan.ScanRecord?) {}
            override fun onBatchScanResults(results: MutableList<android.bluetooth.le.ScanResult>?) {}
        })
    }

    /**
     * Read stored metrics with CommandHandle.executeReqCmd(req, callback).
     * Map each SDK response into the BandVitals shape the Dart side expects.
     * Map BleOperateManager connection callbacks → stateSink (BandState ordinal).
     */
    private fun readLatestVitals(): Map<String, Any?> = mapOf(
        "heartRate" to null, "hrv" to null, "spo2" to null,
        "steps" to null, "battery" to null, "stress" to null, "sleepMinutes" to null,
    )

    private fun sink(field: kotlin.reflect.KMutableProperty0<EventChannel.EventSink?>) =
        object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink?) { field.set(events) }
            override fun onCancel(args: Any?) { field.set(null) }
        }
}
