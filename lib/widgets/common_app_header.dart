import 'package:flutter/material.dart';
import 'offline_badge.dart';

class CommonAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;
  final bool showOfflineBadge;

  const CommonAppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
    this.showOfflineBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 오프라인 배지 (오른쪽 정렬)
          if (showOfflineBadge) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OfflineBadge(),
              ],
            ),
            const SizedBox(height: 4),
          ],
          // 뒤로가기 버튼 + 타이틀 & 서브타이틀
          Row(
            children: [
              IconButton(
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[700], size: 20),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110.0);
}