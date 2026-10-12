import '../models/equipment.dart';

/// 휴대용 온디바이스 보드(Orange Pi)에 미리 동기화해 둔 설비 DB를 흉내낸 것.
///
/// 실제 구조:
///   사무실/와이파이 구역에서 회사 설비 전체 + 이력을 보드에 동기화
///   → 지하 기계실(네트워크 X)에서도 QR 하나로 이력을 바로 조회
///
/// 나중에 실제 DB(sqflite / hive 등)나 보드 API로 바꿀 때는
/// 이 파일의 catalog / historyOf 만 교체하면 됨.
class OnDeviceDb {
  OnDeviceDb._();

  /// 보드에 동기화된 회사 설비 전체
  static const catalog = <Equipment>[
    Equipment(id: 'esc-1', name: '1호기 에스컬레이터', location: '정문 1층'),
    Equipment(id: 'esc-2', name: '2호기 에스컬레이터', location: 'B동 1층'),
    Equipment(id: 'esc-3', name: '3호기 에스컬레이터', location: 'B동 2층'),
    Equipment(id: 'esc-7', name: '7호기 에스컬레이터', location: 'C동 지하 1층'),
    Equipment(id: 'esc-8', name: '8호기 에스컬레이터', location: 'C동 1층'),
  ];

  /// 처음 앱을 켰을 때 '내 담당 설비'로 등록돼 있는 것
  static const defaultMine = ['esc-3', 'esc-2', 'esc-1'];

  static Equipment? find(String id) {
    for (final e in catalog) {
      if (e.id == id) return e;
    }
    return null;
  }

  static List<InspectionRecord> historyOf(String id) =>
      List.unmodifiable(_history[id] ?? const <InspectionRecord>[]);

  // ───────────────────────── 더미 이력 생성 ─────────────────────────

  static final Map<String, List<InspectionRecord>> _history = {
    'esc-1': _generate(months: 13, phase: 0),
    'esc-2': _generate(
      months: 14,
      phase: 1,
      missed: ['브레이크'], // 최근 8개월간 브레이크 점검 누락 → '지연' 표시
      cautions: {1: ['구동체인']},
    ),
    'esc-3': _generate(
      months: 13,
      phase: 5,
      cautions: {1: ['스텝체인'], 4: ['스텝체인']},
    ),
    'esc-7': _generate(
      months: 13,
      phase: 2,
      cautions: {2: ['핸드레일']},
    ),
    'esc-8': _generate(
      months: 14,
      phase: 3,
      missed: ['스텝체인'],
    ),
  };

  static const _inspectors = ['김점검', '이안전', '박철우', '최설비'];

  /// 매달 15일 점검했다고 가정하고 [months]개월치 기록을 만든다.
  /// - [phase]: 3/6/12개월 항목이 몇 월에 걸리는지 설비마다 다르게
  /// - [missed]: 최근 8개월 동안 빠뜨린 항목 (누락 데모용)
  /// - [cautions]: {몇 달 전: [주의 항목]}
  static List<InspectionRecord> _generate({
    required int months,
    required int phase,
    List<String> missed = const [],
    Map<int, List<String>> cautions = const {},
  }) {
    final now = DateTime.now();
    final records = <InspectionRecord>[];

    for (var i = 1; i <= months; i++) {
      final date = DateTime(now.year, now.month - i, 15);
      final k = i + phase;
      final checked = [
        for (final c in CycleItem.all)
          if (k % c.cycleMonths == 0 && !(missed.contains(c.name) && i <= 8))
            c.name,
      ];
      final caution = cautions[i] ?? const <String>[];

      records.add(InspectionRecord(
        date: date,
        inspector: _inspectors[(i + phase) % _inspectors.length],
        durationMinutes: 6 + checked.length * 2,
        status:
            caution.isEmpty ? InspectionStatus.normal : InspectionStatus.caution,
        cautionItems: caution,
        checkedItems: checked,
      ));
    }
    return records; // 최신순
  }
}
