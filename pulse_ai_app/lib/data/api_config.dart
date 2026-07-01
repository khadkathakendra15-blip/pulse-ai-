/// Backend base URL.
///
/// Defaults to the Android-emulator loopback (`10.0.2.2` maps to the host's
/// localhost). Override at build time:
///   flutter run --dart-define=PULSE_API_BASE=http://192.168.1.20:3000/api
class ApiConfig {
  static const base = String.fromEnvironment(
    'PULSE_API_BASE',
    defaultValue: 'http://10.0.2.2:3000/api',
  );
}
