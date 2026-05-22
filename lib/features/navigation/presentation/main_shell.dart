import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.search),
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.circle_plus),
            label: 'Đề xuất',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.info),
            label: 'Giới thiệu',
          ),
        ],
      ),
    );
  }
}

