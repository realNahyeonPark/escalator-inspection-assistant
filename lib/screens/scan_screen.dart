import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../controllers/equipment_repository.dart';
import '../widgets/common_widgets.dart';
import '../widgets/equipment_sheet.dart';
import '../widgets/common_app_header.dart';

enum ScanMode { qr, nfc }

/// 프레임 1 — 설비 스캔 (QR / NFC)
///
/// 스캔 → EquipmentSheet(바텀시트)
///   · 등록된 설비      : 이번 달 필수 항목 + [이력 보기] [점검 시작]
///   · 온디바이스 DB 설비 : [등록하고 이력 가져오기]
///   · DB에 없는 설비    : 이름/위치 입력 후 등록
///
/// 실제 스캔 연동 (지금은 박스를 탭하면 '테스트용 QR 선택' 창이 뜸):
///  - QR  : mobile_scanner 패키지 → _ScannerBox 를 MobileScanner 위젯으로 교체하고
///          onDetect 에서 _handleQr(barcode.rawValue!) 호출
///  - NFC : nfc_manager 패키지 → 태그에서 읽은 문자열로 _handleQr 호출
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _repo = EquipmentRepository.instance;
  ScanMode _mode = ScanMode.qr;

  bool _looking = false;

  /// QR/NFC에서 읽은 문자열로 설비 조회
  Future<void> _handleQr(String raw) async {
    if (_looking) return;

    setState(() => _looking = true);

    try {
      final lookup = await _repo.lookup(raw);

      if (!mounted) return;

      await EquipmentSheet.show(context, lookup);
    } finally {
      if (mounted) {
        setState(() => _looking = false);
      }
    }
  }

  /// 테스트용 QR 선택
  Future<void> _simulateScan() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(
          '테스트용 QR 선택',
          style: TextStyle(fontSize: 17),
        ),
        children: [
          _option(ctx, 'esc-3', '3호기', '등록된 설비'),
          _option(
            ctx,
            'esc-7',
            '7호기',
            '새 설비 · 온디바이스 DB에 이력 있음',
          ),
          _option(
            ctx,
            '{"id":"esc-8"}',
            '8호기 (JSON QR)',
            '새 설비 · 이력 있음 · 누락 항목 있음',
          ),
          _option(
            ctx,
            'esc-99',
            '알 수 없는 QR',
            'DB에 없는 설비 → 직접 등록',
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, '__reset__'),
            child: const Text(
              '테스트 데이터 초기화',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (picked == null || !mounted) return;

    if (picked == '__reset__') {
      await _repo.resetForTest();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('담당 설비를 처음 상태(1·2·3호기)로 되돌렸어요'),
        ),
      );
      return;
    }

    await _handleQr(picked);
  }

  Widget _option(
    BuildContext ctx,
    String payload,
    String title,
    String desc,
  ) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, payload),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppHeader(
        title: '설비 스캔',
        subtitle: _mode == ScanMode.qr
            ? '설비의 QR 코드를 비춰주세요'
            : '설비의 NFC 태그에 휴대폰을 대주세요',
        showBackButton: false,
        showOfflineBadge: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _repo,
              builder: (context, _) {
                final recent = _repo.recentEquipments();

                return ScrollConfiguration(
                  // 스크롤 끝에서 콘텐츠가 늘어나는 효과 제거
                  behavior: ScrollConfiguration.of(context).copyWith(
                    overscroll: false,
                  ),
                  child: ListView(
                    // 스크롤 끝에서 늘어나거나 튕기는 효과 방지
                    physics: const ClampingScrollPhysics(),
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _ScannerBox(
                              mode: _mode,
                              onTap: _simulateScan,
                            ),
                            if (_looking)
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          '박스를 탭하면 테스트용 QR을 고를 수 있어요',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel('최근 점검'),
                      for (final e in recent) ...[
                        Builder(
                          builder: (_) {
                            final latest = _repo.latestOf(e.id);

                            return EquipmentTile(
                              equipment: e,
                              subtitle: latest == null
                                  ? '${e.location} · 기록 없음'
                                  : '${e.location} · ${relativeDay(latest.date)}',
                              trailing: latest == null
                                  ? null
                                  : Pill.status(
                                      latest.status,
                                      count: latest.cautionItems.length,
                                    ),
                              onTap: () => _handleQr(e.id),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// QR | NFC 세그먼트 토글
class _ModeToggle extends StatelessWidget {
  final ScanMode mode;
  final ValueChanged<ScanMode> onChanged;

  const _ModeToggle({
    required this.mode,
    required this.onChanged,
  });

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
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
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
        children: [
          item(ScanMode.qr, 'QR'),
          item(ScanMode.nfc, 'NFC'),
        ],
      ),
    );
  }
}

/// 어두운 스캐너 박스
class _ScannerBox extends StatefulWidget {
  final ScanMode mode;
  final VoidCallback onTap;

  const _ScannerBox({
    required this.mode,
    required this.onTap,
  });

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
                    child: CustomPaint(
                      painter: _CornerPainter(),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => Positioned(
                      left: 20,
                      right: 20,
                      top: 20 + (size - 40) * _anim.value,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 44,
                      color: Color(0xFF8A9099),
                    ),
                  ),
                ],
              )
            : Center(
                child: Container(
                  width: size - 40,
                  height: size - 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4A505A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.nfc,
                    size: 52,
                    color: Color(0xFF8A9099),
                  ),
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

    const m = 16.0;
    const l = 26.0;

    final w = size.width;
    final h = size.height;

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
    canvas.drawLine(
      Offset(w - m, h - m),
      Offset(w - m - l, h - m),
      p,
    );
    canvas.drawLine(
      Offset(w - m, h - m),
      Offset(w - m, h - m - l),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}