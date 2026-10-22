import 'package:flutter/material.dart';
import '../widgets/common_app_header.dart'; // 공통 헤더 임포트

class InspectionEditScreen extends StatefulWidget {
  final String itemName;
  final String initialStatus;
  final String initialRemarks;
  final String initialSpeech;

  // 헤더 제목과 부제목
  final String headerTitle;
  final String headerSubtitle;

  const InspectionEditScreen({
    super.key,
    required this.itemName,
    this.initialStatus = '주의관찰',
    this.initialRemarks = '신장 의심',
    this.initialSpeech =
        '스텝체인이 좀 늘어난 느낌이고 소리도 조금 나요.',

    // 기본값을 지정하므로 required를 붙이지 않음
    this.headerTitle = '점검 결과 수정',
    this.headerSubtitle = '잘못 인식된 정보를 수정합니다',
  });

  @override
  State<InspectionEditScreen> createState() =>
      _InspectionEditScreenState();
}

class _InspectionEditScreenState extends State<InspectionEditScreen> {
  late String selectedStatus;
  late TextEditingController _remarksController;
  late TextEditingController _speechController;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
    _remarksController = TextEditingController(text: widget.initialRemarks);
    _speechController = TextEditingController(text: widget.initialSpeech);
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _speechController.dispose();
    super.dispose();
  }

  // 선택된 상태에 따른 왼쪽 테두리 색상 반환
  Color _getBorderColor() {
    switch (selectedStatus) {
      case '양호':
        return const Color(0xff32a852); // 초록색
      case '주의관찰':
        return const Color(0xff8b4513); // 갈색
      case '수리필요':
        return const Color(0xffe74c3c); // 붉은색
      default:
        return const Color(0xff8b4513);
    }
  }

  // 상태별 선택 시의 활성화 색상 반환 (배경색, 테두리색, 폰트색)
  Map<String, Color> _getStatusColors(String status) {
    bool isSelected = selectedStatus == status;

    if (!isSelected) {
      return {
        'bg': Colors.white,
        'border': Colors.grey.shade300,
        'text': Colors.grey[700]!,
      };
    }

    switch (status) {
      case '양호':
        return {
          'bg': const Color(0xffe8f7ee), // 연한 초록 배경
          'border': const Color(0xff32a852), // 초록 테두리
          'text': const Color(0xff237a3b), // 진한 초록 폰트
        };
      case '주의관찰':
        return {
          'bg': const Color(0xfffbece3), // 연한 갈색(주황빛) 배경
          'border': const Color(0xffd97736), // 갈색 테두리
          'text': const Color(0xffb55312), // 진한 갈색 폰트
        };
      case '수리필요':
        return {
          'bg': const Color(0xfffdedec), // 연한 붉은색 배경
          'border': const Color(0xffe74c3c), // 붉은색 테두리
          'text': const Color(0xffc0392b), // 진한 붉은색 폰트
        };
      default:
        return {
          'bg': Colors.white,
          'border': Colors.grey.shade300,
          'text': Colors.grey[700]!,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      // 👈 공통 헤더 위젯 적용 (PreferredSizeWidget 구현체이므로 appBar에 바로 장착 가능)
      appBar: CommonAppHeader(
        title: widget.headerTitle,
        subtitle: widget.headerSubtitle,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  // 선택된 상태에 따라 왼쪽 테두리 색상이 동적으로 변경됨
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border(
                      left: BorderSide(color: _getBorderColor(), width: 6),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 항목 이름 타이틀
                      Text(
                        widget.itemName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),
                      
                      // 상태 선택 영역
                      const Text(
                        '상태',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['양호', '주의관찰', '수리필요'].map((status) {
                          final colors = _getStatusColors(status);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStatus = status;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colors['bg'],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: colors['border']!,
                                  ),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: colors['text'],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // 특기사항 입력 영역
                      const Text(
                        '특기사항',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xfff0f0f0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 발화 입력 영역
                      const Text(
                        '발화',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _speechController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xfff0f0f0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 하단 '변경 사항 저장' 버튼
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'status': selectedStatus,
                  'remarks': _remarksController.text,
                  'speech': _speechController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4c6ef5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '변경 사항 저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}