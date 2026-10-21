
import 'package:flutter/material.dart';
import 'offline_badge.dart';

class CommonAppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;
  final bool showOfflineBadge;
  final bool showBackButton;

  const CommonAppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
    this.showOfflineBadge = true,
    this.showBackButton = true,
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
          if (showOfflineBadge) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OfflineBadge(),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  onPressed: onBackPressed ??
                      () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
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
