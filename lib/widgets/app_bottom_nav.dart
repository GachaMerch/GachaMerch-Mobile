import 'package:flutter/material.dart';

enum NavTab { home, inventory, profile, shop, history }

class AppBottomNav extends StatelessWidget {
  final NavTab activeTab;
  final String? avatarUrl;
  final void Function(NavTab tab)? onTap;

  const AppBottomNav({
    super.key,
    required this.activeTab,
    this.avatarUrl,
    this.onTap,
  });

  static const Color _subText = Color(0xFF88888A);

  void _handleTap(NavTab tab) {
    if (tab == activeTab) return;
    onTap?.call(tab);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(40),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Expanded(child: _navIcon(NavTab.home, 'assets/icon/home-icon.png')),
          Expanded(child: _navIcon(NavTab.inventory, 'assets/icon/weapon-icon.png')),
          Expanded(child: _navProfile()),
          Expanded(child: _navIcon(NavTab.shop, 'assets/icon/shop-icon.png')),
          Expanded(child: _navIcon(NavTab.history, 'assets/icon/history-icon.png')),
        ],
      ),
    );
  }

  Widget _navIcon(NavTab tab, String asset) {
    final selected = activeTab == tab;
    return Builder(
      builder: (context) => SizedBox(
        height: 48,
        child: GestureDetector(
          onTap: () => _handleTap(tab),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF3A3A3A) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                asset,
                width: 24,
                height: 24,
                color: selected ? Colors.white : _subText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navProfile() {
    final selected = activeTab == NavTab.profile;
    return Builder(
      builder: (context) => SizedBox(
        height: 48,
        child: GestureDetector(
          onTap: () => _handleTap(NavTab.profile),
          child: Center(
            child: Container(
              width: selected ? 40 : 32,
              height: selected ? 40 : 32,
              decoration: selected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    )
                  : null,
              child: ClipOval(
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF3A3A3A),
      child: const Icon(Icons.person, color: _subText, size: 20),
    );
  }
}
