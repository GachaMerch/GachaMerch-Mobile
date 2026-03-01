import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'services/auth_service.dart';
import 'LoginPage.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF2F2F2);
    final card = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? const Color(0xFF88888A) : const Color(0xFF8A8A8E);

    final avatarUrl = user['avatar'] as String?;
    final username = user['username']?.toString() ?? 'Player';

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // banner + back + avatar
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      // banner image
                      SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Opacity(
                              opacity: 0.95,
                              child: Image.asset(
                                'assets/banner/banner-profile.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // gradient overlay — full height
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // back button top-left
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 12,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 22,
                              ),
                              const Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Alexandria',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // avatar overlapping banner bottom
                      Positioned(
                        bottom: -44,
                        child: Stack(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: bg, width: 4),
                              ),
                              child: ClipOval(
                                child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _avatarFallback(card, subText),
                                      )
                                    : _avatarFallback(card, subText),
                              ),
                            ),
                            // camera badge
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A3A),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bg, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  // name
                  Text(
                    username,
                    style: TextStyle(
                      color: text,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Never Surrenders',
                    style: TextStyle(
                      color: subText,
                      fontFamily: 'Alexandria',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // menu items — each in own card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _menuCard(
                          card: card,
                          icon: Icons.manage_accounts_outlined,
                          label: 'Profile Edit',
                          textColor: text,
                          iconColor: subText,
                          trailing: Icon(Icons.chevron_right, color: subText, size: 20),
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _ColorModeCard(card: card, textColor: text, iconColor: subText),
                        const SizedBox(height: 10),
                        _menuCard(
                          card: card,
                          icon: Icons.info_outline,
                          label: 'About Us',
                          textColor: text,
                          iconColor: subText,
                          trailing: Icon(Icons.chevron_right, color: subText, size: 20),
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _menuCard(
                          card: card,
                          icon: Icons.logout,
                          label: 'Log Out',
                          textColor: Colors.redAccent,
                          iconColor: Colors.redAccent,
                          trailing: Icon(Icons.chevron_right, color: Colors.redAccent, size: 20),
                          onTap: () async {
                            await AuthService.logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                                (_) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SafeArea(top: false, child: _buildBottomNav(context)),
        ],
      ),
    );
  }

  Widget _avatarFallback(Color card, Color subText) {
    return Container(
      color: card,
      child: Icon(Icons.person, color: subText, size: 40),
    );
  }

  Widget _menuCard({
    required Color card,
    required IconData icon,
    required String label,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Alexandria',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = user['avatar'] as String?;

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
          Expanded(child: _navIcon(context, 'assets/icon/home-icon.png')),
          Expanded(child: _navIcon(context, 'assets/icon/weapon-icon.png')),
          // profile — active (center)
          Expanded(
            child: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _navAvatarFallback(),
                          )
                        : _navAvatarFallback(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _navIcon(context, 'assets/icon/shop-icon.png')),
          Expanded(child: _navIcon(context, 'assets/icon/history-icon.png')),
        ],
      ),
    );
  }

  Widget _navAvatarFallback() {
    return Container(
      color: const Color(0xFF3A3A3A),
      child: const Icon(Icons.person, color: Color(0xFF88888A), size: 28),
    );
  }

  Widget _navIcon(BuildContext context, String asset) {
    return SizedBox(
      height: 48,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Image.asset(
            asset,
            width: 24,
            height: 24,
            color: const Color(0xFF88888A),
          ),
        ),
      ),
    );
  }
}

class _ColorModeCard extends StatelessWidget {
  final Color card;
  final Color textColor;
  final Color iconColor;

  const _ColorModeCard({
    required this.card,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.contrast, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Color Mode',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Alexandria',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // OverflowBox prevents Switch from affecting card height
              SizedBox(
                height: 22,
                width: 52,
                child: OverflowBox(
                  maxHeight: 48,
                  maxWidth: 52,
                  alignment: Alignment.center,
                  child: Switch(
                    value: isDark,
                    onChanged: (val) {
                      if (val) {
                        AdaptiveTheme.of(context).setDark();
                      } else {
                        AdaptiveTheme.of(context).setLight();
                      }
                    },
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFD4AF37);
                      }
                      return null;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

