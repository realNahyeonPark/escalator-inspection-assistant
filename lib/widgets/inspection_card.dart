import 'package:flutter/material.dart';

class InspectionCard extends StatelessWidget {
  final String title;
  final String? statusText;
  final String? remarks;
  final String? speech;
  final VoidCallback onEditPressed;
  final VoidCallback? onDirectCheckPressed; // 구동체인처럼 결과가 없을 때용

  const InspectionCard({
    super.key,
    required this.title,
    this.statusText,
    this.remarks,
    this.speech,
    required this.onEditPressed,
    this.onDirectCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 점검 결과가 없는 경우 (Missing Card)
    if (statusText == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, color: Colors.amber[800], size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title 점검 결과가 없습니다.",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "이상 없음으로 기록할까요?",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onEditPressed, // 여기선 보통 직접 입력으로 연결하거나 수정창 띄움
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("이상 기록 없음"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDirectCheckPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("직접 점검"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. 일반 점검 결과 카드 (스텝체인, 핸드레일, 구동체인 완료 시)
    Color accentColor;
    Color statusColor;
    Color statusBgColor;

    switch (statusText) {
      case '양호':
        accentColor = const Color(0xFF32A852);
        statusColor = const Color(0xFF32A852);
        statusBgColor = const Color(0xFFE8F7EE);
        break;
      case '수리필요':
        accentColor = const Color(0xFFE74C3C);
        statusColor = const Color(0xFFE74C3C);
        statusBgColor = const Color(0xFFFDEDEC);
        break;
      default: // 주의관찰 등
        accentColor = const Color(0xFF8B4513);
        statusColor = const Color(0xFFF78F45);
        statusBgColor = const Color(0xFFFFF2E8);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 160,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText!,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "상태: $statusText | ${remarks ?? ''}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    speech ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: onEditPressed,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                            const SizedBox(width: 4),
                            Text(
                              "수정",
                              style: TextStyle(
                                  color: Colors.blue[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}