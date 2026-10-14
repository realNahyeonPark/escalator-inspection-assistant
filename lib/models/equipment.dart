/// 점검 결과 상태
enum InspectionStatus { normal, caution }

/// 설비 (에스컬레이터 등)
class Equipment {
  final String id; // QR/NFC 에 들어있는 값. 예: esc-3
  final String name; // 예: 3호기 에스컬레이터
  final String location; // 예: B동 2층
  final EquipmentSpec? spec; // 기본제원 (정기검사기준 3.1)

  const Equipment({
    required this.id,
    required this.name,
    required this.location,
    this.spec,
  });

  /// '3호기 에스컬레이터' → '3호기'
  String get shortName => name.replaceAll(' 에스컬레이터', '');

  /// API 응답(escalatorId) / 로컬 저장(id) 둘 다 읽음
  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: (json['escalatorId'] ?? json['id']).toString(),
        name: json['name'] as String? ?? '이름 없음',
        location: json['location'] as String? ?? '',
        spec: json['spec'] is Map
            ? EquipmentSpec.fromJson(Map<String, dynamic>.from(json['spec'] as Map))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'escalatorId': id,
        'name': name,
        'location': location,
        if (spec != null) 'spec': spec!.toJson(),
      };
}

/// 기본제원 — 「에스컬레이터 정기검사기준」 3.1 항목
/// (승강기안전종합정보망 정보와 일치해야 하는 값들)
class EquipmentSpec {
  final String elevatorNo; // 승강기번호
  final String? certNo; // 승강기 인증번호
  final String? model; // 모델명/제품명
  final String? manufacturer; // 제조업체명
  final double? floorHeightM; // 층고 (m)
  final int? inclineDeg; // 경사도 (°)
  final int? nominalWidthMm; // 공칭폭 (mm)
  final double? ratedSpeed; // 정격속도 (m/s)
  final String? driveType; // 구동 운전방식: 인버터식 / Y-△식 / 직결식
  final String? lubrication; // 디딤판 체인 윤활: 자동식 / 수동식
  final List<String> notApplicable; // 이 설비에서 '해당없음'인 항목 (설비마다 고정)

  const EquipmentSpec({
    required this.elevatorNo,
    this.certNo,
    this.model,
    this.manufacturer,
    this.floorHeightM,
    this.inclineDeg,
    this.nominalWidthMm,
    this.ratedSpeed,
    this.driveType,
    this.lubrication,
    this.notApplicable = const [],
  });

  factory EquipmentSpec.fromJson(Map<String, dynamic> j) => EquipmentSpec(
        elevatorNo: '${j['elevatorNo'] ?? ''}',
        certNo: j['certNo'] as String?,
        model: j['model'] as String?,
        manufacturer: j['manufacturer'] as String?,
        floorHeightM: (j['floorHeightM'] as num?)?.toDouble(),
        inclineDeg: (j['inclineDeg'] as num?)?.toInt(),
        nominalWidthMm: (j['nominalWidthMm'] as num?)?.toInt(),
        ratedSpeed: (j['ratedSpeed'] as num?)?.toDouble(),
        driveType: j['driveType'] as String?,
        lubrication: j['lubrication'] as String?,
        notApplicable: List<String>.from(j['notApplicable'] ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'elevatorNo': elevatorNo,
        'certNo': certNo,
        'model': model,
        'manufacturer': manufacturer,
        'floorHeightM': floorHeightM,
        'inclineDeg': inclineDeg,
        'nominalWidthMm': nominalWidthMm,
        'ratedSpeed': ratedSpeed,
        'driveType': driveType,
        'lubrication': lubrication,
        'notApplicable': notApplicable,
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
