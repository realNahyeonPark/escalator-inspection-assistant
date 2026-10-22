import 'package:flutter/material.dart';

import '../models/inspection_item.dart';
import '../models/equipment.dart';
import '../controllers/equipment_repository.dart';
import '../widgets/common_app_header.dart';
import '../widgets/common_widgets.dart';
import 'voice_inspection_screen.dart';
import 'inspection_result_page.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final EquipmentRepository _repo = EquipmentRepository.instance;

  String? _equipmentId;
  Equipment? _equipment;
  bool _routeArgumentsRead = false;

  final List<InspectionItem> inspectionItems = [
    InspectionItem(
      id: '1',
      title: '핸드레일',
      description: '점검 필요',
      cycle: '월간',
      isChecked: false,
    ),
    InspectionItem(
      id: '2',
      title: '스텝·라이저',
      description: '점검 필요',
      cycle: '월간',
      isChecked: false,
    ),
    InspectionItem(
      id: '3',
      title: '콤브',
      description: '점검 필요',
      cycle: '월간',
      isChecked: false,
    ),
    InspectionItem(
      id: '4',
      title: '스텝체인',
      description: '점검 필요',
      cycle: '3개월',
      isChecked: false,
    ),
    InspectionItem(
      id: '5',
      title: '구동체인',
      description: '점검 필요',
      cycle: '3개월',
      isChecked: false,
    ),
    InspectionItem(
      id: '6',
      title: '브레이크',
      description: '점검 필요',
      cycle: '3개월',
      isChecked: false,
    ),
  ];

  /// 라우트에서 전달받은 설비 ID로 실제 설비 정보를 조회
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_routeArgumentsRead) return;
  _routeArgumentsRead = true;

  final arguments = ModalRoute.of(context)?.settings.arguments;

  if (arguments is String && arguments.isNotEmpty) {
    _equipmentId = arguments;
    _equipment = _repo.equipmentOf(arguments);
  }
}

  /// 음성 점검 화면 열기
  ///
  /// 아직 완료하지 않은 항목 중 첫 번째 항목부터 점검

Future<void> _startVoiceInspection() async {
  final equipmentId = _equipmentId;

  if (equipmentId == null || equipmentId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('설비 정보를 확인할 수 없습니다.'),
      ),
    );
    return;
  }

  // 체크되지 않은 항목만 점검 대상으로 구성
  final pendingItems = inspectionItems
      .where((item) => !item.isChecked)
      .toList();

  // 미완료 항목을 하나씩 순서대로 점검
  for (var i = 0; i < pendingItems.length; i++) {
    final item = pendingItems[i];

    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceInspectionScreen(
          equipmentId: equipmentId,
          itemId: item.id,
          itemName: item.title,
          isLastItem: i == pendingItems.length - 1,
        ),
      ),
    );

    if (!mounted) return;

    // 점검 완료 버튼이 아니라 뒤로가기를 눌렀으면
    // 전체 점검 흐름을 중단
    if (completed != true) return;
  }

  if (!mounted) return;

  // 모든 미완료 항목의 음성 점검 화면을 거친 뒤
  // 결과 페이지를 한 번만 표시
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      settings: RouteSettings(
        arguments: {
          'equipmentId': equipmentId,
          'inspectionItems': inspectionItems,
        },
      ),
      builder: (context) => const InspectionResultPage(),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final completedCount =
        inspectionItems.where((item) => item.isChecked).length;
    final totalCount = inspectionItems.length;

    final equipment = _equipment;

    // 실제 설비 위치 표시
    final locationText = equipment == null
        ? (_equipmentId == null
            ? '설비 정보 없음'
            : '설비 ID: $_equipmentId')
        : (equipment.location.isEmpty
            ? '위치 미입력'
            : equipment.location);

    // 저장소에 기록된 마지막 점검 정보 조회
    final latest = _equipmentId == null
        ? null
        : _repo.latestOf(_equipmentId!);

    final lastInspectionText = latest == null
        ? '기록 없음'
        : '마지막 점검 ${relativeDay(latest.date)}';

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      // 기존 공통 헤더 유지
      appBar: const CommonAppHeader(
        title: '점검 항목',
        subtitle: '오늘 수행할 항목입니다',
      ),

      body: Column(
        children: [
          // 설비 정보 카드: 고정된 3호기 정보 대신 실제 정보 표시
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff4c6ef5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment?.name ??
                        (_equipmentId == null
                            ? '설비 정보 없음'
                            : '설비 ID: $_equipmentId'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$locationText · $lastInspectionText',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: totalCount > 0
                        ? completedCount / totalCount
                        : 0,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalCount개 중 $completedCount개 완료',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '이번 점검 대상',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 점검 항목 리스트
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: inspectionItems.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = inspectionItems[index];

                final statusText =
                    item.isChecked ? '이상 없음' : '점검 필요';
                final statusColor = item.isChecked
                    ? Colors.grey[600]!
                    : const Color(0xffe74c3c);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.isChecked,
                        onChanged: (val) {
                          setState(() {
                            item.isChecked = val ?? false;
                          });

                          // TODO: 백엔드 상태 업데이트 연동
                        },
                        activeColor: const Color(0xff1aa179),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 13,
                                color: statusColor,
                                fontWeight: item.isChecked
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 공통 Pill 위젯으로 점검 주기 표시
                      Pill.cycle(item.cycle),
                    ],
                  ),
                );
              },
            ),
          ),

          // 하단 음성 점검 시작 버튼
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startVoiceInspection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4c6ef5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '음성으로 점검 시작',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
