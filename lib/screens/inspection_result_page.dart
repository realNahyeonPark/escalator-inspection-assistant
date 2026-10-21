import 'package:esc_application/screens/inspection_edit_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/common_app_header.dart';
import '../widgets/inspection_card.dart';

class InspectionResultPage extends StatefulWidget {
  const InspectionResultPage({super.key});

  @override
  State<InspectionResultPage> createState() => _InspectionResultPageState();
}

class _InspectionResultPageState extends State<InspectionResultPage> {
  final List<Map<String, dynamic>> results = [
    {
      'title': '스텝체인',
      'status': '주의관찰',
      'remarks': '신장 의심',
      'speech': "'스텝체인이 좀 늘어난 느낌이고 소리도 조금 나요.'",
    },
    {
      'title': '핸드레일',
      'status': '양호',
      'remarks': '정상',
      'speech': "'핸드레일 양호합니다.'",
    },
    {
      'title': '구동체인',
      'status': null,
      'remarks': null,
      'speech': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CommonAppHeader(
        title: "점검 결과",
        subtitle: "결과를 말씀해주세요",
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: results.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = results[index];
                  return InspectionCard(
                    title: item['title'],
                    statusText: item['status'],
                    remarks: item['remarks'],
                    speech: item['speech'],
                    onEditPressed: () async {
                      // 수정 화면으로 이동 및 결과 반영 로직
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InspectionEditScreen(
                            itemName: item['title'],
                            initialStatus: item['status'] ?? '양호',
                            initialRemarks: item['remarks'] ?? '',
                            initialSpeech: (item['speech'] ?? '').replaceAll("'", ""),
                          ),
                        ),
                      );

                      if (res != null && res is Map<String, String>) {
                        setState(() {
                          results[index]['status'] = res['status'];
                          results[index]['remarks'] = res['remarks'];
                          results[index]['speech'] = res['speech'];
                        });
                      }
                    },
                    onDirectCheckPressed: () async {
                      // 구동체인 '직접 점검' 버튼 누를 때
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InspectionEditScreen(
                            itemName: item['title'],
                            initialStatus: '양호',
                          ),
                        ),
                      );

                      if (res != null && res is Map<String, String>) {
                        setState(() {
                          results[index]['status'] = res['status'];
                          results[index]['remarks'] = res['remarks'];
                          results[index]['speech'] = res['speech'];
                        });
                      }
                    },
                  );
                },
              ),
            ),
            // 하단 저장 버튼
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("점검 결과 저장", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}