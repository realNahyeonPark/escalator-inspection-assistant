import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/mock_data.dart';
import '../widgets/common_widgets.dart';

enum ScanMode { qr, nfc }

/// 프레임 1 — 설비 스캔 (QR / NFC)
///
/// 실제 스캔 연동:
///  - QR  : mobile_scanner 패키지 → _ScannerBox 안의 박스를 MobileScanner 위젯으로 교체
///  - NFC : nfc_manager 패키지 → _startNfcSession() 에서 NfcManager.instance.startSession
/// 지금은 박스를 탭하면 스캔 성공으로 가정하고 점검 화면으로 이동함.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ScanMode _mode = ScanMode.qr;

  void _onScanned(String equipmentId) {
    // 프레임 3(점검 항목) 담당자 화면으로 이동. 라우트 이름은 main.dart 기준.
    Navigator.pushNamed(context, '/inspect', arguments: equipmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: '설비 스캔',
          subtitle: _mode == ScanMode.qr
              ? '설비의 QR 코드를 비춰주세요'
              : '설비의 NFC 태그에 휴대폰을 대주세요',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Center(
                child: _ModeToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _ScannerBox(
                  mode: _mode,
                  onTap: () => _onScanned('esc-3'),
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel('최근 점검'),
              for (final e in MockData.recentEquipments) ...[
                EquipmentTile(equipment: e, onTap: () => _onScanned(e.id)),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// QR | NFC 세그먼트 토글
class _ModeToggle extends StatelessWidget {
  final ScanMode mode;
  final ValueChanged<ScanMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget item(ScanMode m, String label) {
      final selected = mode == m;
      return GestureDetector(
        onTap: () => onChanged(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              )),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.toggleBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [item(ScanMode.qr, 'QR'), item(ScanMode.nfc, 'NFC')],
      ),
    );
  }
}

/// 어두운 스캐너 박스 (QR: 모서리 가이드 + 움직이는 스캔 라인 / NFC: 아이콘)
class _ScannerBox extends StatefulWidget {
  final ScanMode mode;
  final VoidCallback onTap;

  const _ScannerBox({required this.mode, required this.onTap});

  @override
  State<_ScannerBox> createState() => _ScannerBoxState();
}

class _ScannerBoxState extends State<_ScannerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 220.0;
    final isQr = widget.mode == ScanMode.qr;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.scannerBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isQr
            ? Stack(
                children: [
                  const Positioned.fill(
                      child: CustomPaint(painter: _CornerPainter())),
                  // 스캔 라인
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => Positioned(
                      left: 20,
                      right: 20,
                      top: 20 + (size - 40) * _anim.value,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.6),
                                blurRadius: 8)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.qr_code_2,
                        size: 44, color: Color(0xFF8A9099)),
                  ),
                ],
              )
            : Center(
                child: Container(
                  width: size - 40,
                  height: size - 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: const Color(0xFF4A505A), width: 2),
                  ),
                  child: const Icon(Icons.nfc,
                      size: 52, color: Color(0xFF8A9099)),
                ),
              ),
      ),
    );
  }
}

/// QR 가이드 모서리 4개
class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const m = 16.0; // 여백
    const l = 26.0; // 모서리 길이
    final w = size.width, h = size.height;

    // 좌상
    canvas.drawLine(const Offset(m, m), const Offset(m + l, m), p);
    canvas.drawLine(const Offset(m, m), const Offset(m, m + l), p);
    // 우상
    canvas.drawLine(Offset(w - m, m), Offset(w - m - l, m), p);
    canvas.drawLine(Offset(w - m, m), Offset(w - m, m + l), p);
    // 좌하
    canvas.drawLine(Offset(m, h - m), Offset(m + l, h - m), p);
    canvas.drawLine(Offset(m, h - m), Offset(m, h - m - l), p);
    // 우하
    canvas.drawLine(Offset(w - m, h - m), Offset(w - m - l, h - m), p);
    canvas.drawLine(Offset(w - m, h - m), Offset(w - m, h - m - l), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
