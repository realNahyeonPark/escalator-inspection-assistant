import 'package:flutter/material.dart';

class VoiceInspectionScreen extends StatefulWidget {
  final String itemName; // 어떤 항목을 점검 중인지 받아옵니다 (예: '스텝체인')

  const VoiceInspectionScreen({super.key, required this.itemName});

  @override
  State<VoiceInspectionScreen> createState() => _VoiceInspectionScreenState();
}

class _VoiceInspectionScreenState extends State<VoiceInspectionScreen>
    with TickerProviderStateMixin {
  bool isListening = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // 파동 애니메이션 컨트롤러 설정 (지속 시간을 2초로 늘려 더 부드럽고 천천히 퍼지도록 설정)
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
        _waveController.repeat(); // 듣고 있는 동안 파동 애니메이션 반복
      } else {
        _waveController.stop(); // 멈추면 애니메이션 정지
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // 헤더 타이틀 (동적으로 전달받은 항목 이름 표시)
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.itemName} 점검',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '결과를 말씀해주세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 중앙 마이크 아이콘 및 파동 효과 영역
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 듣고 있는 중일 때만 퍼져나가는 파동 애니메이션 표시
                if (isListening) ...[
                  // 첫 번째 파동 (기본 지연 없음)
                  _buildWaveCircle(scaleFactor: 1.6, delayOffset: 0.0),
                  // 두 번째 파동 (지연을 주어 첫 번째 파동과 간격을 두고 천천히 따라 나옴)
                  _buildWaveCircle(scaleFactor: 2.1, delayOffset: 0.5),
                ],
                // 중앙 마이크 버튼
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xff4c6ef5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff4c6ef5).withOpacity(0.3),
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
            isListening ? '말씀을 듣고 있습니다...' : '버튼을 누르고 말씀해주세요',
            style: TextStyle(
              fontSize: 15,
              color: isListening ? const Color(0xff4c6ef5) : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // 음성 인식 텍스트가 표시될 입력 박스 모양의 컨테이너
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
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // 하단 재생/일시정지 버튼 (정지 시 빨간색, 크기 확대)
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 78, // 기존 68에서 크기 키움
              height: 78,
              decoration: BoxDecoration(
                // 듣고 있을 때는 빨간색 정지 버튼, 대기 중일 때는 초록색 재생 버튼
                color: isListening ? const Color(0xffe74c3c) : const Color(0xff6ab04c),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isListening ? const Color(0xffe74c3c) : const Color(0xff6ab04c)).withOpacity(0.4),
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
          // 하단 '점검 완료' 버튼
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 이전 화면으로 돌아가기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4c6ef5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '점검 완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 마이크 주변으로 시간차를 두고 퍼져나가는 파동 원을 만들어주는 헬퍼 위젯
  Widget _buildWaveCircle({required double scaleFactor, required double delayOffset}) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        // 지연 시간(delayOffset)을 반영하여 각 파동이 순차적으로 나타나도록 계산
        double progress = (_waveController.value - delayOffset) % 1.0;
        if (progress < 0) progress += 1.0;

        return Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0), // 퍼져나갈수록 투명해짐
          child: Transform.scale(
            scale: 1.0 + (scaleFactor - 1.0) * progress, // 크기가 점점 커짐
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff4c6ef5).withOpacity(0.6),
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