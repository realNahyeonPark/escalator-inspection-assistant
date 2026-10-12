import 'equipment.dart';

/// 백엔드 연결 전까지 쓰는 더미 데이터.
/// 나중에 controllers/ 에서 API 응답(JSON)을 fromJson 으로 바꿔 끼우면 됨.
class MockData {
  MockData._();

  static const recentEquipments = [
    Equipment(
      id: 'esc-3',
      name: '3호기 에스컬레이터',
      location: 'B동 2층',
      lastInspected: '어제',
      status: InspectionStatus.normal,
    ),
    Equipment(
      id: 'esc-2',
      name: '2호기 에스컬레이터',
      location: 'B동 1층',
      lastInspected: '3일 전',
      status: InspectionStatus.caution,
      cautionCount: 1,
    ),
  ];

  static const allEquipments = [
    Equipment(
      id: 'esc-3',
      name: '3호기 에스컬레이터',
      location: 'B동 2층',
      lastInspected: '어제',
      status: InspectionStatus.normal,
    ),
    Equipment(
      id: 'esc-2',
      name: '2호기 에스컬레이터',
      location: 'B동 1층',
      lastInspected: '3일 전',
      status: InspectionStatus.caution,
      cautionCount: 1,
    ),
    Equipment(
      id: 'esc-1',
      name: '1호기 에스컬레이터',
      location: '정문 1층',
      lastInspected: '1주 전',
      status: InspectionStatus.normal,
    ),
  ];

  static List<InspectionRecord> historyOf(String equipmentId) => [
        InspectionRecord(
          date: DateTime(2026, 9, 14),
          inspector: '김점검',
          durationMinutes: 12,
          status: InspectionStatus.caution,
          cautionItems: const ['스텝체인'],
        ),
        InspectionRecord(
          date: DateTime(2026, 8, 15),
          inspector: '이안전',
          durationMinutes: 10,
          status: InspectionStatus.normal,
        ),
        InspectionRecord(
          date: DateTime(2026, 7, 16),
          inspector: '김점검',
          durationMinutes: 11,
          status: InspectionStatus.normal,
        ),
        InspectionRecord(
          date: DateTime(2026, 6, 15),
          inspector: '박설비',
          durationMinutes: 14,
          status: InspectionStatus.caution,
          cautionItems: const ['스텝체인'],
        ),
      ];
}
