import 'package:dio/dio.dart';

import 'api_config.dart';

/// Live numbers from `GET /api/health/dashboard`. The app overlays these onto
/// the (bilingual) presentation copy in [PulseData]; nulls fall back to demo.
class DashboardData {
  final bool bandConnected;
  final int health;
  final int recovery;
  final int readiness;
  final Map<String, num?> vitals;
  const DashboardData({
    required this.bandConnected,
    required this.health,
    required this.recovery,
    required this.readiness,
    required this.vitals,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) {
    final scores = (j['scores'] ?? {}) as Map<String, dynamic>;
    return DashboardData(
      bandConnected: (j['bandConnected'] ?? false) as bool,
      health: (scores['health'] ?? 0) as int,
      recovery: (scores['recovery'] ?? 0) as int,
      readiness: (scores['readiness'] ?? 0) as int,
      vitals: ((j['vitals'] ?? {}) as Map).map((k, v) => MapEntry(k.toString(), v as num?)),
    );
  }
}

/// Thin REST client for the Pulse AI backend (NestJS). Holds the JWT in memory;
/// persist it with your preferred secure storage for real sessions.
class PulseApi {
  PulseApi({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.base));

  final Dio _dio;
  String? _token;

  bool get isAuthenticated => _token != null;

  Options get _auth => Options(headers: _token == null ? null : {'Authorization': 'Bearer $_token'});

  Future<void> register(String email, String password, {String? name, String lang = 'np'}) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
      'locale': lang,
    });
    _token = res.data['accessToken'] as String?;
  }

  Future<void> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    _token = res.data['accessToken'] as String?;
  }

  void useToken(String token) => _token = token;

  Future<DashboardData> dashboard() async {
    final res = await _dio.get('/health/dashboard', options: _auth);
    return DashboardData.fromJson(res.data as Map<String, dynamic>);
  }

  /// Upload band samples — each: {metric, value, unit?, recordedAt(ISO8601), source?}.
  Future<int> ingest(List<Map<String, dynamic>> samples) async {
    final res = await _dio.post('/health/samples', data: {'samples': samples}, options: _auth);
    return (res.data['inserted'] ?? 0) as int;
  }

  /// Ask Pulse Coach. Returns the raw reply map (kind/text/analysis fields).
  Future<Map<String, dynamic>> coach(String message, {String lang = 'np', String? promptKey}) async {
    final res = await _dio.post('/ai/coach', data: {
      'message': message,
      'lang': lang,
      if (promptKey != null) 'promptKey': promptKey,
    }, options: _auth);
    return res.data as Map<String, dynamic>;
  }
}
