/// 점검 결과 상태
enum InspectionStatus { normal, caution }

/// 설비 (에스컬레이터 등)
class Equipment {
  final String id; // QR/NFC 에 들어있는 값. 예: esc-3
  final String name; // 예: 3호기 에스컬레이터
  final String location; // 예: B동 2층

  const Equipment({
    required this.id,
    required this.name,
    required this.location,
  });

  /// '3호기 에스컬레이터' → '3호기'
  String get shortName => name.replaceAll(' 에스컬레이터', '');

  /// API 응답(escalatorId) / 로컬 저장(id) 둘 다 읽음
  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: (json['escalatorId'] ?? json['id']).toString(),
        name: json['name'] as String? ?? '이름 없음',
        location: json['location'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'escalatorId': id,
        'name': name,
        'location': location,
      };
}

/// 설비 1건에 대한 점검 기록 (이력 타임라인 1칸)
class InspectionRecord {
  final DateTime date;
  final String inspector;
  final int durationMinutes;
  final InspectionStatus status;
  final List<String> cautionItems; // 주의 판정 항목. 예: ['스텝체인']
  final List<String> checkedItems; // 이번에 점검한 항목 (주기 계산에 사용)
  final String? inspectionId; // 결과 화면(/api/inspections/{id}) 연결용
  final String? note; // 특이사항

  const InspectionRecord({
    required this.date,
    required this.inspector,
    required this.durationMinutes,
    required this.status,
    this.cautionItems = const [],
    this.checkedItems = const [],
    this.inspectionId,
    this.note,
  });

  /// API 응답(inspectedAt, "CAUTION") / 로컬 저장(date, "caution") 둘 다 읽음
  factory InspectionRecord.fromJson(Map<String, dynamic> json) =>
      InspectionRecord(
        date: DateTime.parse((json['inspectedAt'] ?? json['date']) as String),
        inspector: json['inspector'] as String? ?? '',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
        status: '${json['status']}'.toLowerCase() == 'caution'
            ? InspectionStatus.caution
            : InspectionStatus.normal,
        cautionItems: List<String>.from(json['cautionItems'] ?? const []),
        checkedItems: List<String>.from(json['checkedItems'] ?? const []),
        inspectionId: json['inspectionId']?.toString(),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'inspectionId': inspectionId,
        'inspectedAt': date.toIso8601String(),
        'inspector': inspector,
        'durationMinutes': durationMinutes,
        'status': status.name.toUpperCase(),
        'cautionItems': cautionItems,
        'checkedItems': checkedItems,
        'note': note,
      };
}

/// 주기별 점검 항목 (1 / 3 / 6 / 12개월)
/// ※ 팀원의 InspectionItem(프레임 3 체크리스트)과 이름(title)을 맞춰 쓰면 됨.
class CycleItem {
  final String name;
  final int cycleMonths;

  const CycleItem(this.name, this.cycleMonths);

  String get cycleLabel => switch (cycleMonths) {
        1 => '월간',
        12 => '연간',
        _ => '$cycleMonths개월',
      };

  static const all = [
    CycleItem('핸드레일', 1),
    CycleItem('스텝 라이저', 1),
    CycleItem('스텝체인', 3),
    CycleItem('구동체인', 3),
    CycleItem('브레이크', 6),
    CycleItem('안전장치 종합', 12),
  ];
}

enum DueLevel {
  overdue, // 지난 주기를 놓침 (빨강)
  thisMonth, // 이번 달에 해야 함 (파랑)
}

/// 이번에 꼭 해야 하는 점검 항목 (누락 방지 안내)
class DueItem {
  final CycleItem item;
  final DateTime? lastDone; // null = 기록 없음
  final DueLevel level;

  const DueItem(this.item, this.lastDone, this.level);
}
