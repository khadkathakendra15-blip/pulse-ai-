# Pulse AI

A pixel-faithful Flutter rebuild of the **Pulse AI** mockup (`Pulse AI App - Standalone.html`) — an AI health companion for the **QRing (Android)** and **QWatchPro / QCBandSDK (iOS)** wearables.

Dark theme · mint `#2BE3A0` accent · Manrope + Space Grotesk + Mukta fonts · **bilingual Nepali/English** · 5 tabs: **Today, Coach, Score, Insights, Body**.

---

## Status

| Layer | State |
|---|---|
| UI / UX (all 5 screens, nav, bilingual toggle, expandable cards, AI-coach chat) | ✅ Complete, matches the mockup |
| Demo data (`PulseData`) | ✅ Full port of the mockup's `renderVals()` |
| SDK bridge — Dart side (`BandBridge`, repository) | ✅ Done |
| SDK bridge — native side (QRing AAR / QCBandSDK) | ⚠️ Templates provided in `native_templates/`, not yet wired |

Until the native handlers are added the app runs in **demo mode** (the "Band Live" pill shows "Demo") with the mockup data — exactly the look of the original.

---

## Run it

Flutter is **not installed** on this machine. Install it first: <https://docs.flutter.dev/get-started/install/windows>

```bash
cd "D:/Pulse Ai/pulse_ai_app"
flutter create .          # generates android/ ios/ windows/ … platform folders
flutter pub get
flutter run               # pick an emulator or device
```

`flutter create .` keeps everything under `lib/`, `pubspec.yaml`, etc. and only adds the missing platform scaffolding.

> **Fonts:** `google_fonts` downloads Manrope / Space Grotesk / Mukta on first launch (needs network once). To ship offline, drop the `.ttf` files in `assets/fonts/`, declare them in `pubspec.yaml`, and swap the `GoogleFonts.*` calls in `lib/theme/typography.dart` for `TextStyle(fontFamily: …)`.

---

## Project layout

```
lib/
  main.dart                 app shell + 5-tab IndexedStack
  app_state.dart            ChangeNotifier — tab, language, toggles, chat, band state
  theme/
    colors.dart             exact palette from the mockup
    typography.dart         Manrope / Space Grotesk / Mukta helpers (+ NP switch)
  data/
    models.dart             typed data classes
    mock_data.dart          bilingual port of renderVals() (the demo data)
    band_channel.dart       Dart side of the platform bridge to the SDKs
  widgets/
    rings.dart              animated progress rings (CustomPainter)
    common.dart             cards, glow blob, pills, mini-bars, track bars
    bottom_nav.dart         frosted 5-tab nav
  screens/                  home / coach / score / insights / body
native_templates/
  android/BandPlugin.kt     QRing (oudmon) MethodChannel handler template
  ios/BandPlugin.swift      QCBandSDK MethodChannel handler template
```

---

## Native SDK wiring (going live)

The Dart side already talks to these channels (`lib/data/band_channel.dart`):

| channel | type | purpose |
|---|---|---|
| `pulse_ai/band` | Method | startScan / stopScan / connect / disconnect / isConnected / latestVitals |
| `pulse_ai/band/scan` | Event | discovered devices |
| `pulse_ai/band/state` | Event | connection state (BandState ordinal) |
| `pulse_ai/band/vitals` | Event | live metric stream |

1. **Android** — drop `qring_sdk_1.0.0.27.aar` into `android/app/libs/`, follow the header in `native_templates/android/BandPlugin.kt`, and map the SDK's `CommandHandle`/`BleOperateManager` callbacks into the channel payloads.
2. **iOS** — add the QCBandSDK framework (request an `.xcframework` from the vendor — see the SDK review), follow `native_templates/ios/BandPlugin.swift`. Remember: **QCSDKCmdCreator commands must be issued sequentially.**
3. Once `latestVitals` / the vitals stream return real numbers, overlay them onto `PulseData` in a `SdkHealthRepository` so the same screens render live data.

### Health-claim caveat
The rings/bands report blood-pressure, SpO₂ and (some) blood-glucose. These are **wellness estimates, not medical readings** — keep the framing non-diagnostic in any shipping build.
