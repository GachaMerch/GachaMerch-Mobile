import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'services/auth_service.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/app_bottom_nav.dart';
import 'InventoryPage.dart';
import 'ShopPage.dart';
import 'LoginPage.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _user = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user);
  }

  Color get _bg => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1F1F1F)
      : const Color(0xFFF2F2F2);
  Color get _card => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2A2A2A)
      : Colors.white;
  Color get _text => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF1A1A1A);
  Color get _subText => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF88888A)
      : const Color(0xFF8A8A8E);

  void _showProfileEditDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => ProfileEditDialog(
        user: _user,
        onSaved: (updated) => setState(() => _user = {..._user, ...updated}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bg;
    final card = _card;
    final text = _text;
    final subText = _subText;

    final avatarUrl = _user['avatar'] as String?;
    final username = _user['username']?.toString() ?? 'Player';
    final status = _user['status']?.toString() ?? 'Never Surrenders';

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
                    status,
                    style: TextStyle(
                      color: subText,
                      fontFamily: 'Alexandria',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // menu items
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
                          onTap: _showProfileEditDialog,
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
          SafeArea(
            top: false,
            child: AppBottomNav(
              activeTab: NavTab.profile,
              avatarUrl: _user['avatar'] as String?,
              onTap: (tab) {
                if (tab == NavTab.home) {
                  Navigator.pop(context);
                } else if (tab == NavTab.inventory) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => InventoryPage(user: _user)),
                  );
                } else if (tab == NavTab.shop) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ShopPage(user: _user)),
                  );
                }
              },
            ),
          ),
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

}

// ── Color Mode Card ────────────────────────────────────────────────────────────

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
