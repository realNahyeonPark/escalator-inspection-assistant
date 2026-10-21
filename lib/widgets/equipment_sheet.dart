import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../controllers/equipment_repository.dart';
import '../models/equipment.dart';
import '../screens/home_screen.dart';
import 'common_widgets.dart';

/// QR/NFC 스캔 직후 아래에서 올라오는 설비 카드.
///
///  - 등록된 설비      → 최근 점검 + 이번 달 필수 항목 + [이력 보기] [점검 시작]
///  - 온디바이스 DB 설비 → "이력 N건 발견" + [등록하고 이력 가져오기]
///  - DB에 없는 설비    → 이름/위치 입력해서 새로 등록
class EquipmentSheet extends StatefulWidget {
  final ScanLookup lookup;

  const EquipmentSheet({super.key, required this.lookup});

  static Future<void> show(BuildContext context, ScanLookup lookup) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EquipmentSheet(lookup: lookup),
    );
  }

  @override
  State<EquipmentSheet> createState() => _EquipmentSheetState();
}

class _EquipmentSheetState extends State<EquipmentSheet> {
  final _repo = EquipmentRepository.instance;
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _elevatorNoCtrl = TextEditingController();

  Equipment? _equipment;
  bool _justImported = false; // 방금 이력을 가져왔는지 (안내 문구용)

  @override
  void initState() {
    super.initState();
    _equipment = widget.lookup.equipment;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _elevatorNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerFromDb() async {
    await _repo.register(_equipment!);
    setState(() => _justImported = true);
  }

  Future<void> _registerNew() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final elevatorNo = _elevatorNoCtrl.text.trim();
    final e = Equipment(
      id: widget.lookup.id,
      name: name,
      location: _locationCtrl.text.trim(),
      spec: elevatorNo.isEmpty ? null : EquipmentSpec(elevatorNo: elevatorNo),
    );
    await _repo.register(e);
    setState(() => _equipment = e);
  }

  void _openHistory() {
    final nav = Navigator.of(context);
    final e = _equipment!;
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => HistoryDetailScreen(equipment: e)));
  }

  void _startInspection() {
    final nav = Navigator.of(context);
    final id = _equipment!.id;
    nav.pop();
    nav.pushNamed('/inspect', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // 키보드
    final registered = _equipment != null && _repo.isMine(_equipment!.id);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
         child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _typePill(registered),
            const SizedBox(height: 10),
            if (_equipment == null)
              ..._unknownBody()
            else ...[
              Text(_equipment!.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                  '${_equipment!.location.isEmpty ? '위치 미입력' : _equipment!.location} · QR ${widget.lookup.id}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              EquipmentSpecCard(spec: _equipment!.spec),
              const SizedBox(height: 16),
              if (registered) ..._registeredBody() else ..._inDbBody(),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _typePill(bool registered) {
    if (registered) {
      return Pill(
        label: _justImported ? '등록 완료' : '등록된 설비',
        color: AppColors.normal,
        background: AppColors.normalBg,
      );
    }
    if (widget.lookup.type == ScanResultType.inDeviceDb) {
      return const Pill(
          label: '새 설비 감지',
          color: AppColors.primary,
          background: AppColors.primaryBg);
    }
    return const Pill(
        label: 'DB에 없는 설비',
        color: AppColors.warning,
        background: AppColors.warningBg);
  }

  // ── 온디바이스 DB 에 있는 새 설비 ──
  List<Widget> _inDbBody() {
    final history = _repo.historyOf(_equipment!.id);
    return [
      widget.lookup.fromServer
          ? _InfoBox(
              icon: Icons.cloud_done,
              text: '서버에서 점검 이력 ${history.length}건을 받았어요.\n'
                  '등록하면 기기에 저장돼서 오프라인에서도 볼 수 있어요.',
            )
          : _InfoBox(
              icon: Icons.memory,
              text: '온디바이스 DB에서 점검 이력 ${history.length}건을 찾았어요.\n'
                  '네트워크 없이 바로 가져올 수 있어요.',
            ),
      const SizedBox(height: 16),
      _PrimaryButton(label: '등록하고 이력 가져오기', onPressed: _registerFromDb),
    ];
  }

  // ── 등록된 설비 ──
  List<Widget> _registeredBody() {
    final id = _equipment!.id;
    final latest = _repo.latestOf(id);
    final history = _repo.historyOf(id);
    final due = _repo.dueItems(id);

    return [
      if (_justImported) ...[
        _InfoBox(
          icon: Icons.check_circle,
          color: AppColors.normal,
          text: '이력 ${history.length}건을 가져왔어요. 점검 기록 탭에서도 볼 수 있어요.',
        ),
        const SizedBox(height: 14),
      ],
      Row(
        children: [
          const Text('최근 점검',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text(
            latest == null ? '기록 없음' : formatDate(latest.date),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          if (latest != null)
            Pill.status(latest.status, count: latest.cautionItems.length),
        ],
      ),
      const SizedBox(height: 14),
      const Text('이번 점검 필수 항목',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      if (history.isEmpty)
        const Text('점검 이력이 없어요. 첫 점검에서 전체 항목을 확인하세요.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
      else
        DueChips(items: due),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _openHistory,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('이력 보기',
                  style: TextStyle(color: AppColors.textPrimary)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _PrimaryButton(label: '점검 시작', onPressed: _startInspection),
          ),
        ],
      ),
    ];
  }

  // ── DB 에도 없는 설비 ──
  List<Widget> _unknownBody() {
    return [
      Text('QR ${widget.lookup.id}',
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      const _InfoBox(
        icon: Icons.info_outline,
        color: AppColors.warning,
        text: '온디바이스 DB에 없는 설비예요.\n정보를 입력하면 새 설비로 등록하고 첫 점검부터 기록돼요.',
      ),
      const SizedBox(height: 14),
      _input(_nameCtrl, '설비 이름 (예: 9호기 에스컬레이터)'),
      const SizedBox(height: 8),
      _input(_locationCtrl, '위치 (예: D동 2층)'),
      const SizedBox(height: 8),
      _input(_elevatorNoCtrl, '승강기번호 (예: 2104-390, 승강기 표지에 적힌 번호)'),
      const SizedBox(height: 16),
      _PrimaryButton(label: '새 설비로 등록', onPressed: _registerNew),
    ];
  }

  Widget _input(TextEditingController c, String hint) => TextField(
        controller: c,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, height: 1.4, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
