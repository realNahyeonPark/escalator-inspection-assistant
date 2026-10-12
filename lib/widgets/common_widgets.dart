import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/equipment.dart';

// ───────────────────────── 날짜 표시 헬퍼 ─────────────────────────

String formatDate(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

/// 오늘 / 어제 / 3일 전 / 2주 전 / 2026.06.15
String relativeDay(DateTime d) {
  final now = DateTime.now();
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (days <= 0) return '오늘';
  if (days == 1) return '어제';
  if (days < 7) return '$days일 전';
  if (days < 31) return '${days ~/ 7}주 전';
  return formatDate(d);
}

// ───────────────────────── 헤더 ─────────────────────────

/// 상단 제목 + 부제목 (뒤로가기 버튼, 오른쪽 위젯 선택)
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          if (onBack != null) ...[
            Material(
              color: AppColors.toggleBg,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.chevron_left,
                      size: 20, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 오른쪽 위 '● 온디바이스' 표시 (네트워크 없이 동작 중)
class OnDeviceChip extends StatelessWidget {
  const OnDeviceChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.memory, size: 12, color: AppColors.primary),
          SizedBox(width: 4),
          Text('온디바이스',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ───────────────────────── 배지 ─────────────────────────

/// 둥근 배지
class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const Pill({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  /// 정상 / 주의 N
  factory Pill.status(InspectionStatus status, {String? label, int count = 0}) {
    final normal = status == InspectionStatus.normal;
    return Pill(
      label: label ?? (normal ? '정상' : '주의 $count'),
      color: normal ? AppColors.normal : AppColors.warning,
      background: normal ? AppColors.normalBg : AppColors.warningBg,
    );
  }

  /// 이번 달 필수 개수 (지연 있으면 빨강)
  static Widget? due(List<DueItem> due) {
    if (due.isEmpty) return null;
    final overdue = due.where((d) => d.level == DueLevel.overdue).length;
    return overdue > 0
        ? Pill(
            label: '지연 $overdue',
            color: AppColors.danger,
            background: AppColors.dangerBg)
        : Pill(
            label: '이번 달 ${due.length}',
            color: AppColors.primary,
            background: AppColors.primaryBg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// 이번에 꼭 해야 하는 점검 항목들 (누락 방지)
class DueChips extends StatelessWidget {
  final List<DueItem> items;

  const DueChips({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.normal),
          SizedBox(width: 6),
          Text('이번 달 필수 항목을 모두 완료했어요',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final d in items)
          Pill(
            label: d.level == DueLevel.overdue
                ? '${d.item.name} · ${d.lastDone == null ? '기록 없음' : '지연'}'
                : '${d.item.name} · ${d.item.cycleLabel}',
            color: d.level == DueLevel.overdue
                ? AppColors.danger
                : AppColors.primary,
            background: d.level == DueLevel.overdue
                ? AppColors.dangerBg
                : AppColors.primaryBg,
          ),
      ],
    );
  }
}

// ───────────────────────── 카드 / 목록 ─────────────────────────

/// 흰색 둥근 카드
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 설비 카드 (스캔 화면 '최근 점검' / 기록 화면 목록 공용)
class EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const EquipmentTile({
    super.key,
    required this.equipment,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(equipment.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 검색창
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchField(
      {super.key, required this.hint, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c),
        );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search,
            size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary),
      ),
    );
  }
}

/// 섹션 라벨 ('최근 점검', '검색 결과')
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      );
}
