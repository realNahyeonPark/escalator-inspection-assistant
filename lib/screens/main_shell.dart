import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';

/// 하단 탭: 설비 스캔(프레임 1) / 점검 기록(프레임 2)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [ScanScreen(), HomeScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          height: 64,
          backgroundColor: AppColors.surface,
          indicatorColor: Colors.transparent,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner, color: AppColors.textSecondary),
              selectedIcon:
                  Icon(Icons.qr_code_scanner, color: AppColors.primary),
              label: '설비 스캔',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.cloud, color: AppColors.primary),
              label: '점검 기록',
            ),
          ],
        ),
      ),
    );
  }
}
