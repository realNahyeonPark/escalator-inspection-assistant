import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/equipment.dart';

/// 상단 제목 + 부제목 (뒤로가기 버튼 선택)
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
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
        ],
      ),
    );
  }
}

/// 상태 배지: 정상 / 주의 N / 전체 정상 / 주의 1 · 스텝체인
class StatusBadge extends StatelessWidget {
  final String label;
  final InspectionStatus status;

  const StatusBadge({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final isNormal = status == InspectionStatus.normal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNormal ? AppColors.normalBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNormal ? AppColors.normal : AppColors.warning,
        ),
      ),
    );
  }
}

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

/// 설비 카드 (스캔 화면 '최근 점검' / 기록 화면 '검색 결과' 공용)
class EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final bool showStatus;
  final VoidCallback? onTap;

  const EquipmentTile({
    super.key,
    required this.equipment,
    this.showStatus = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final e = equipment;
    final badgeLabel = e.status == InspectionStatus.normal
        ? '정상'
        : '주의 ${e.cautionCount}';
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  showStatus ? '${e.location} · ${e.lastInspected}' : e.location,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (showStatus) StatusBadge(label: badgeLabel, status: e.status),
        ],
      ),
    );
  }
}

/// 검색창 (점검 기록 / 설비 이력)
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchField(
      {super.key, required this.hint, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
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
