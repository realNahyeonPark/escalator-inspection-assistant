
import 'package:esc_application/screens/inspection_edit_screen.dart';
import 'package:flutter/material.dart';

import '../models/inspection_item.dart';
import '../widgets/common_app_header.dart';
import '../widgets/inspection_card.dart';

class InspectionResultPage extends StatefulWidget {
  const InspectionResultPage({super.key});

  @override
  State<InspectionResultPage> createState() =>
      _InspectionResultPageState();
}

class _InspectionResultPageState
    extends State<InspectionResultPage> {
  String? _equipmentId;
  List<InspectionItem> _inspectionItems = [];

  bool _routeArgumentsRead = false;

  // 일반 결과 카드로 표시할 항목 ID
  // 1: 핸드레일, 4: 스텝체인
  static const Set<String> _normalCardItemIds = {'1', '4'};

  // 점검 결과 목록
  final List<Map<String, dynamic>> results = [
    {
      'id': '4',
      'title': '스텝체인',
      'status': '주의관찰',
      'remarks': '신장 의심',
      'speech': "'스텝체인이 좀 늘어난 느낌이고 소리도 조금 나요.'",
    },
    {
      'id': '1',
      'title': '핸드레일',
      'status': '양호',
      'remarks': '정상',
      'speech': "'핸드레일 양호합니다.'",
    },
  ];

  /// 이전 화면에서 전달받은 설비 및 점검 항목 정보
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeArgumentsRead) return;
    _routeArgumentsRead = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! Map) return;

    _equipmentId = arguments['equipmentId']?.toString();

    final receivedItems = arguments['inspectionItems'];

    if (receivedItems is List<InspectionItem>) {
      _inspectionItems = receivedItems;
      _buildResultsFromChecklist();
    }
  }

  /// 체크박스 상태에 따라 결과 카드 구성
  void _buildResultsFromChecklist() {
    results.clear();

    // 핸드레일과 스텝체인:
    // 체크되지 않은 항목만 기존 결과 카드로 표시
    for (final itemId in ['4', '1']) {
      for (final item in _inspectionItems) {
        if (item.id != itemId || item.isChecked) continue;

        if (item.id == '4') {
          results.add({
            'id': item.id,
            'title': item.title,
            'status': '주의관찰',
            'remarks': '신장 의심',
            'speech':
                "'스텝체인이 좀 늘어난 느낌이고 소리도 조금 나요.'",
          });
        } else {
          results.add({
            'id': item.id,
            'title': item.title,
            'status': '양호',
            'remarks': '정상',
            'speech': "'핸드레일 양호합니다.'",
          });
        }
      }
    }

    // 나머지 부품:
    // 체크되지 않은 경우 결과 없음 카드로 표시
    for (final item in _inspectionItems) {
      if (item.isChecked) continue;
      if (_normalCardItemIds.contains(item.id)) continue;

      results.add({
        'id': item.id,
        'title': item.title,
        'status': null,
        'remarks': null,
        'speech': null,
      });
    }
  }

  /// 기존 결과 수정 화면 열기
  Future<void> _editResult(int index) async {
    final item = results[index];

    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionEditScreen(
          itemName: item['title'],
          initialStatus: item['status'] ?? '양호',
          initialRemarks: item['remarks'] ?? '',
          initialSpeech:
              (item['speech'] ?? '').replaceAll("'", ""),

          // 기존 결과 수정 화면의 헤더
          headerTitle: '점검 결과 수정',
          headerSubtitle: '잘못 인식된 정보를 수정합니다',
        ),
      ),
    );

    if (!mounted) return;

    if (res is Map<String, String>) {
      setState(() {
        results[index]['status'] = res['status'];
        results[index]['remarks'] = res['remarks'];
        results[index]['speech'] = res['speech'];
      });
    }
  }

  /// '이상 기록 없음' 버튼:
  /// 수정 화면으로 이동하지 않고 바로 정상 카드로 변경
  void _recordNoIssue(int index) {
    setState(() {
      results[index]['status'] = '양호';
      results[index]['remarks'] = '음성 인식 없이 정상 기록';
      results[index]['speech'] = null;
    });
  }

  /// '직접 입력' 버튼:
  /// 제목이 '점검 결과 입력'인 화면 열기
  Future<void> _directInput(int index) async {
    final item = results[index];

    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionEditScreen(
          itemName: item['title'],
          initialStatus: '양호',
          initialRemarks: '',
          initialSpeech: '',
          headerTitle: '점검 결과 입력',
          headerSubtitle: '점검 결과를 직접 입력합니다',
        ),
      ),
    );

    if (!mounted) return;

    if (res is Map<String, String>) {
      setState(() {
        results[index]['status'] = res['status'];
        results[index]['remarks'] = res['remarks'];
        results[index]['speech'] = res['speech'];
      });
    }
  }

  /// 점검 결과 저장 확인 모달
  Future<void> _confirmSave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('점검 결과 저장'),
          content: const Text('점검 결과를 저장하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('아니오'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('예'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    // TODO: _equipmentId와 results를 서버 또는 DB에 저장
    // 현재는 실제 데이터 저장 없이 메인 화면으로 이동
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CommonAppHeader(
        title: '점검 결과',
        subtitle: '결과를 말씀해주세요',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: results.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = results[index];

                  return InspectionCard(
                    title: item['title'],
                    statusText: item['status'],
                    remarks: item['remarks'],
                    speech: item['speech'],

                    // 결과가 없으면 정상으로 바로 변경하고,
                    // 기존 결과 카드라면 수정 화면 열기
                    onEditPressed: () {
                      if (item['status'] == null) {
                        _recordNoIssue(index);
                      } else {
                        _editResult(index);
                      }
                    },

                    // '직접 입력' 버튼
                    onDirectCheckPressed: () {
                      _directInput(index);
                    },
                  );
                },
              ),
            ),

            // 하단 점검 결과 저장 버튼
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: _confirmSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  '점검 결과 저장',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
