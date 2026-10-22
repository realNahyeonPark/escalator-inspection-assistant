
import 'package:flutter/material.dart';
import '../widgets/common_app_header.dart';

class VoiceInspectionScreen extends StatefulWidget {
  final String equipmentId;
  final String itemId;
  final String itemName;
  final bool isLastItem;

  const VoiceInspectionScreen({
    super.key,
    required this.equipmentId,
    required this.itemId,
    required this.itemName,
    required this.isLastItem,
  });

  @override
  State<VoiceInspectionScreen> createState() =>
      _VoiceInspectionScreenState();
}

class _VoiceInspectionScreenState extends State<VoiceInspectionScreen>
    with TickerProviderStateMixin {
  bool isListening = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // 파동 애니메이션 컨트롤러
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  // 버튼 클릭 시 음성 인식 상태 토글
  void _toggleListening() {
    setState(() {
      isListening = !isListening;

      if (isListening) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    });
  }

  // 현재 점검 항목 완료 후 InspectionScreen으로 복귀
  void _finishCurrentItem() {
    if (isListening) {
      setState(() {
        isListening = false;
      });

      _waveController.stop();
    }

    // true를 반환하면 InspectionScreen에서 다음 항목으로 진행
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: CommonAppHeader(
        title: '${widget.itemName} 점검',
        subtitle: '결과를 말씀해주세요',
      ),

      body: Column(
        children: [
          const Spacer(),

          // 중앙 마이크 아이콘 및 파동 효과
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isListening) ...[
                  _buildWaveCircle(
                    scaleFactor: 1.6,
                    delayOffset: 0.0,
                  ),
                  _buildWaveCircle(
                    scaleFactor: 2.1,
                    delayOffset: 0.5,
                  ),
                ],

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xff4c6ef5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff4c6ef5)
                            .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // 상태 안내 텍스트
          Text(
            isListening
                ? '말씀을 듣고 있습니다...'
                : '버튼을 누르고 말씀해주세요',
            style: TextStyle(
              fontSize: 15,
              color: isListening
                  ? const Color(0xff4c6ef5)
                  : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // 음성 인식 텍스트 표시 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                isListening ? '음성 인식 중...' : '',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 음성 듣기 시작 / 정지 버튼
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: isListening
                    ? const Color(0xffe74c3c)
                    : const Color(0xff6ab04c),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isListening
                            ? const Color(0xffe74c3c)
                            : const Color(0xff6ab04c))
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isListening ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),

          const Spacer(),

          // 현재 항목 완료 후 다음 항목 또는 결과 확인
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishCurrentItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4c6ef5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.isLastItem ? '점검 결과 확인' : '다음 항목',
                style: const TextStyle(
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

  // 시간차를 두고 퍼져나가는 파동 원
  Widget _buildWaveCircle({
    required double scaleFactor,
    required double delayOffset,
  }) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        double progress =
            (_waveController.value - delayOffset) % 1.0;

        if (progress < 0) progress += 1.0;

        return Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 1.0 + (scaleFactor - 1.0) * progress,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff4c6ef5)
                      .withValues(alpha: 0.6),
                  width: 2.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
