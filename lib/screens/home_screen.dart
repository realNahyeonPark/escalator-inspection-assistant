import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/equipment.dart';
import '../models/mock_data.dart';
import '../widgets/common_widgets.dart';

/// 프레임 2 (왼쪽) — 점검 기록: 설비 검색 + 목록
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = MockData.allEquipments
        .where((e) =>
            _query.isEmpty ||
            e.name.contains(_query) ||
            e.location.contains(_query))
        .toList();

    return Column(
      children: [
        const PageHeader(title: '점검 기록', subtitle: '설비별 점검 기록을 확인합니다'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              SearchField(
                hint: '에스컬레이터 검색',
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: 20),
              const SectionLabel('검색 결과'),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('검색 결과가 없습니다',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              for (final e in results) ...[
                EquipmentTile(
                  equipment: e,
                  showStatus: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(equipment: e)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 프레임 2 (오른쪽) — N호기 이력: 타임라인
class HistoryDetailScreen extends StatelessWidget {
  final Equipment equipment;

  const HistoryDetailScreen({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    final records = MockData.historyOf(equipment.id);
    final shortName = equipment.name.replaceAll(' 에스컬레이터', '');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '$shortName 이력',
              subtitle: '최근 점검 기록을 확인합니다',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // TODO: 음성 검색은 controllers/ 의 STT 붙이면 마이크 버튼 연결
                  const SearchField(hint: "음성 검색: '지난 스텝체인 결과'"),
                  const SizedBox(height: 20),
                  for (var i = 0; i < records.length; i++)
                    _TimelineItem(
                      record: records[i],
                      isLast: i == records.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final InspectionRecord record;
  final bool isLast;

  const _TimelineItem({required this.record, required this.isLast});

  String _fmt(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isNormal = record.status == InspectionStatus.normal;
    final dotColor = isNormal ? AppColors.normal : AppColors.danger;
    final badgeLabel = isNormal
        ? '전체 정상'
        : '주의 ${record.cautionItems.length} · ${record.cautionItems.join(', ')}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 점 + 세로선
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1.5, color: AppColors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () {
                  // TODO: 프레임 4(점검 결과) 화면으로 이동
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fmt(record.date),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                        '점검자 · ${record.inspector} · ${record.durationMinutes}분 소요',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    StatusBadge(label: badgeLabel, status: record.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
