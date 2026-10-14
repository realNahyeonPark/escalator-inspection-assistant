import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/equipment.dart';

/// 서버 설정
class ApiConfig {
  ApiConfig._();

  /// 백엔드가 준비되면 true 로. false 면 서버 호출 없이 온디바이스 DB만 사용.
  static const bool useServer = false;

  /// 안드로이드 에뮬레이터에서 내 PC 의 localhost = 10.0.2.2
  /// 실제 폰/배포 서버면 그 주소로 변경.
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const Duration timeout = Duration(seconds: 5);
}

/// 404 — 서버에 없는 에스컬레이터
class ApiNotFound implements Exception {}

/// 서버 꺼짐 / 네트워크 없음 / 타임아웃 / 5xx → 온디바이스 데이터로 대체
class ApiOffline implements Exception {
  final Object cause;
  ApiOffline(this.cause);
  @override
  String toString() => 'ApiOffline($cause)';
}

/// API 명세서 (노션) 기준 — 프레임 1·2 담당분
///
/// | 화면            | Method | Endpoint                                   |
/// |-----------------|--------|--------------------------------------------|
/// | QR / NFC 스캔    | GET    | /api/escalators/{escalatorId}              |
/// | 최근 점검 이력    | GET    | /api/escalators/{escalatorId}/histories    |
/// | 점검 기록 / 설비 이력 | GET | /api/escalators/{escalatorId}/histories    |
///
/// ※ 명세서에 응답 JSON 형식이 아직 없어서 아래 형식을 가정함.
///   백엔드와 필드명이 다르면 models/equipment.dart 의 fromJson 만 고치면 됨.
///
/// GET /api/escalators/esc-3
/// {
///   "escalatorId": "esc-3",
///   "name": "3호기 에스컬레이터",
///   "location": "B동 2층"
/// }
///
/// GET /api/escalators/esc-3/histories
/// [
///   {
///     "inspectionId": "insp-101",
///     "inspectedAt": "2026-09-14T10:30:00",
///     "inspector": "김점검",
///     "durationMinutes": 12,
///     "status": "CAUTION",              // NORMAL | CAUTION
///     "checkedItems": ["핸드레일", "스텝체인"],
///     "cautionItems": ["스텝체인"],
///     "note": "스텝체인 장력 약간 느슨함"   // 특이사항 (선택)
///   }
/// ]
/// ( { "data": ... } 로 한 번 감싸서 와도 처리됨 )
class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  final http.Client _http = http.Client();

  Future<dynamic> _get(String path) async {
    if (!ApiConfig.useServer) throw ApiOffline('useServer = false');

    final res = await _http
        .get(Uri.parse('${ApiConfig.baseUrl}$path'))
        .timeout(ApiConfig.timeout)
        .catchError((Object e) => throw ApiOffline(e)); // 연결 실패, 타임아웃 등

    if (res.statusCode == 404) throw ApiNotFound();
    if (res.statusCode >= 400) throw ApiOffline('HTTP ${res.statusCode}');

    final body = jsonDecode(utf8.decode(res.bodyBytes));
    return (body is Map && body.containsKey('data')) ? body['data'] : body;
  }

  /// QR / NFC 스캔, 설비 정보
  Future<Equipment> getEscalator(String escalatorId) async {
    final data =
        await _get('/api/escalators/${Uri.encodeComponent(escalatorId)}');
    return Equipment.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// 최근 점검 이력 / 점검 기록 / 설비 이력 (최신순으로 정렬해서 반환)
  Future<List<InspectionRecord>> getHistories(String escalatorId) async {
    final data = await _get(
        '/api/escalators/${Uri.encodeComponent(escalatorId)}/histories');
    final list = data is List ? data : (data as Map)['histories'] as List;
    final records = [
      for (final m in list)
        InspectionRecord.fromJson(Map<String, dynamic>.from(m as Map)),
    ];
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }
}
