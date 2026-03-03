import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Color _bg(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  Color _card(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _text(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  Color _sub(BuildContext context) => const Color(0xFF88888A);

  @override
  Widget build(BuildContext context) {
    final bg   = _bg(context);
    final card = _card(context);
    final text = _text(context);
    final sub  = _sub(context);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── header banner ──────────────────────────────────────────
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/banner/banner-1.png',
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left, color: Colors.white, size: 22),
                      Text(
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
              // title bottom-left of banner
              Positioned(
                bottom: 16,
                left: 20,
                child: Text(
                  'About Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Alexandria',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),

          // ── content ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // app intro
                  _Section(
                    card: card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/icon/coin.png', width: 22, height: 22),
                            const SizedBox(width: 10),
                            Text(
                              'GachaMerch',
                              style: TextStyle(
                                color: text,
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'GachaMerch adalah platform merchandise digital bertema Genshin Impact. '
                          'Kumpulkan senjata ikonik favoritmu, dari Skyward Blade hingga Wolf\'s Gravestone, '
                          'langsung dari genggamanmu.',
                          style: TextStyle(
                            color: sub,
                            fontFamily: 'Alexandria',
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // features
                  _Section(
                    card: card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fitur Utama',
                          style: TextStyle(
                            color: text,
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Feature(icon: Icons.storefront_outlined, label: 'Shop', desc: 'Beli senjata pilihan dengan koin yang kamu miliki.', text: text, sub: sub),
                        _Feature(icon: Icons.inventory_2_outlined, label: 'Inventory', desc: 'Kelola koleksi senjata yang sudah kamu miliki.', text: text, sub: sub),
                        _Feature(icon: Icons.notifications_none, label: 'Notifikasi', desc: 'Pantau riwayat transaksi dan update terbaru.', text: text, sub: sub),
                        _Feature(icon: Icons.brightness_4_outlined, label: 'Dark / Light Mode', desc: 'Tampilan yang nyaman di segala kondisi.', text: text, sub: sub),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // team
                  _Section(
                    card: card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tim Pengembang',
                          style: TextStyle(
                            color: text,
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TeamMember(name: 'Andrian Pratama', role: 'Mobile Developer', sub: sub, text: text),
                        const SizedBox(height: 12),
                        _TeamMember(name: 'Felix Juan', role: 'Backend Developer', sub: sub, text: text),
                        const SizedBox(height: 12),
                        _TeamMember(name: 'Rachel Jessica Tan', role: 'UI/UX Designer', sub: sub, text: text),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // version & disclaimer
                  _Section(
                    card: card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(label: 'Versi', value: '1.0.0', text: text, sub: sub),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Platform', value: 'Android', text: text, sub: sub),
                        const SizedBox(height: 12),
                        Text(
                          'GachaMerch tidak berafiliasi dengan HoYoverse. '
                          'Semua nama dan aset karakter/senjata adalah milik HoYoverse.',
                          style: TextStyle(
                            color: sub,
                            fontFamily: 'Alexandria',
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── helpers ────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  final Color card;
  const _Section({required this.child, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color text;
  final Color sub;
  const _Feature({required this.icon, required this.label, required this.desc, required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: sub, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: text, fontFamily: 'Alexandria', fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: sub, fontFamily: 'Alexandria', fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String role;
  final Color text;
  final Color sub;
  const _TeamMember({required this.name, required this.role, required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.person, color: Colors.white70, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(color: text, fontFamily: 'Alexandria', fontSize: 14, fontWeight: FontWeight.w600)),
            Text(role, style: TextStyle(color: sub, fontFamily: 'Alexandria', fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color text;
  final Color sub;
  const _InfoRow({required this.label, required this.value, required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: sub, fontFamily: 'Alexandria', fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(color: text, fontFamily: 'Alexandria', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
