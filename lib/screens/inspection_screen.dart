import 'package:flutter/material.dart';
import '../models/inspection_item.dart';
import 'voice_inspection_screen.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  // 처음 시작할 때 체크박스가 비어있도록(isChecked: false) 초기화
  List<InspectionItem> inspectionItems = [
    InspectionItem(id: '1', title: '핸드레일', description: '점검 필요', cycle: '월간', isChecked: false),
    InspectionItem(id: '2', title: '스텝·라이저', description: '점검 필요', cycle: '월간', isChecked: false),
    InspectionItem(id: '3', title: '콤브', description: '점검 필요', cycle: '월간', isChecked: false),
    InspectionItem(id: '4', title: '스텝체인', description: '점검 필요', cycle: '3개월', isChecked: false),
    InspectionItem(id: '5', title: '구동체인', description: '점검 필요', cycle: '3개월', isChecked: false),
    InspectionItem(id: '6', title: '브레이크', description: '점검 필요', cycle: '3개월', isChecked: false),
  ];

  @override
  Widget build(BuildContext context) {
    int completedCount = inspectionItems.where((item) => item.isChecked).length;
    int totalCount = inspectionItems.length;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[700], size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 오프라인 상태 바
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffe8f0fe),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xff4c6ef5), size: 14),
                  SizedBox(width: 4),
                  Text(
                    '오프라인 작동',
                    style: TextStyle(
                      color: Color(0xff4c6ef5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 헤더 타이틀
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('점검 항목', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('오늘 수행할 항목입니다', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          // 설비 정보 카드 (스캔된 에스컬레이터 정보)
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
                  const Text('3호기 에스컬레이터', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('B동 2층 - 마지막 점검 30일 전', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: totalCount > 0 ? completedCount / totalCount : 0,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text('$totalCount개 중 $completedCount개 완료', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('이번 점검 대상', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          // 리스트뷰
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: inspectionItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = inspectionItems[index];
                
                // 체크 여부에 따라 텍스트 동적 결정 (이상 없음 / 점검 필요)
                final statusText = item.isChecked ? '이상 없음' : '점검 필요';
                final statusColor = item.isChecked ? Colors.grey[600]! : const Color(0xffe74c3c);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.isChecked,
                        onChanged: (val) {
                          setState(() {
                            item.isChecked = val!;
                          });
                          // TODO: 백엔드 상태 업데이트 연동
                        },
                        activeColor: const Color(0xff1aa179),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              statusText, // 동적으로 바뀐 텍스트 출력
                              style: TextStyle(
                                fontSize: 13,
                                color: statusColor, // 체크되면 회색, 안 되면 빨간색
                                fontWeight: item.isChecked ? FontWeight.normal : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.cycle == '월간' ? const Color(0xffe8f0fe) : const Color(0xfff3e8ff),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.cycle,
                          style: TextStyle(
                            color: item.cycle == '월간' ? const Color(0xff4c6ef5) : const Color(0xffa55eea),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceInspectionScreen(itemName: '스텝체인'), 
                    // 필요에 따라 어떤 항목을 점검하는지 이름을 넘겨줄 수 있습니다.
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4c6ef5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('음성으로 점검 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}