/// 점검 상태
enum InspectionStatus { normal, caution }

/// 설비 (에스컬레이터 등)
class Equipment {
  final String id;
  final String name; // 예: 3호기 에스컬레이터
  final String location; // 예: B동 2층
  final String lastInspected; // 예: 어제, 3일 전
  final InspectionStatus status;
  final int cautionCount;

  const Equipment({
    required this.id,
    required this.name,
    required this.location,
    required this.lastInspected,
    required this.status,
    this.cautionCount = 0,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String,
        lastInspected: json['lastInspected'] as String? ?? '',
        status: json['status'] == 'caution'
            ? InspectionStatus.caution
            : InspectionStatus.normal,
        cautionCount: json['cautionCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'lastInspected': lastInspected,
        'status': status.name,
        'cautionCount': cautionCount,
      };
}

/// 설비 1건에 대한 점검 기록 (이력 화면 타임라인 1칸)
class InspectionRecord {
  final DateTime date;
  final String inspector;
  final int durationMinutes;
  final InspectionStatus status;
  final List<String> cautionItems; // 예: ['스텝체인']

  const InspectionRecord({
    required this.date,
    required this.inspector,
    required this.durationMinutes,
    required this.status,
    this.cautionItems = const [],
  });

  factory InspectionRecord.fromJson(Map<String, dynamic> json) =>
      InspectionRecord(
        date: DateTime.parse(json['date'] as String),
        inspector: json['inspector'] as String,
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        status: json['status'] == 'caution'
            ? InspectionStatus.caution
            : InspectionStatus.normal,
        cautionItems: List<String>.from(json['cautionItems'] ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'inspector': inspector,
        'durationMinutes': durationMinutes,
        'status': status.name,
        'cautionItems': cautionItems,
      };
}
