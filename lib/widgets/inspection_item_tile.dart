
import 'package:flutter/material.dart';

import '../models/inspection_item.dart';
import 'common_widgets.dart';

class InspectionItemTile extends StatelessWidget {
  final InspectionItem item;
  final ValueChanged<bool?> onChanged;

  const InspectionItemTile({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusText =
        item.isChecked ? '이상 없음' : '점검 필요';

    final statusColor = item.isChecked
        ? Colors.grey[600]!
        : const Color(0xffe74c3c);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: onChanged,
            activeColor: const Color(0xff1aa179),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: item.isChecked
                        ? FontWeight.normal
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Pill.cycle(item.cycle),
        ],
      ),
    );
  }
}
