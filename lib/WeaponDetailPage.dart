import 'package:flutter/material.dart';

const Color _bg = Color(0xFF1F1F1F);
const Color _card = Color(0xFF2A2A2A);
const Color _text = Color(0xFFFFFFFF);
const Color _subText = Color(0xFF88888A);
const Color _gold = Color(0xFFFFD700);

const String _mediaBaseUrl = String.fromEnvironment(
  'MEDIA_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class WeaponDetailPage extends StatelessWidget {
  final Map<String, dynamic> weapon;

  const WeaponDetailPage({super.key, required this.weapon});

  @override
  Widget build(BuildContext context) {
    final imagePath = weapon['Image'] as String? ?? '';
    final imageUrl = imagePath.isNotEmpty ? '$_mediaBaseUrl$imagePath' : null;
    final rarity = (weapon['Rarity'] as num?)?.toInt() ?? 0;
    final price = weapon['Price']?.toString() ?? '0';
    final discount = double.tryParse(weapon['DiscountAmount']?.toString() ?? '0') ?? 0;
    final baseAtk = weapon['BaseAtk']?.toString() ?? '-';
    final subStat = weapon['SubStat']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shop Card Details',
          style: TextStyle(
            color: _text,
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weapon image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
            ),
            const SizedBox(height: 16),

            // Stars
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 18,
                  color: i < rarity ? _gold : _subText,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Name + Type
            Text(
              weapon['Title']?.toString() ?? '',
              style: const TextStyle(
                color: _text,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weapon['Type']?.toString() ?? '',
              style: const TextStyle(
                color: _subText,
                fontFamily: 'Alexandria',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            _statRow('Base ATK', baseAtk),
            const SizedBox(height: 8),
            _statRow(subStat == '-' ? 'Sub Stat' : subStat, '-'),
            const SizedBox(height: 16),

            // Divider
            Divider(color: _card),
            const SizedBox(height: 12),

            // Passive
            if (weapon['PassiveName'] != null && weapon['PassiveName'] != '-') ...[
              Text(
                weapon['PassiveName'].toString(),
                style: const TextStyle(
                  color: _text,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (weapon['PassiveDesc'] != null && weapon['PassiveDesc'] != '-')
              Text(
                weapon['PassiveDesc'].toString(),
                style: const TextStyle(
                  color: _subText,
                  fontFamily: 'Alexandria',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 24),

            // Price button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A3A3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: _text, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      discount > 0
                          ? 'Buy – ${(double.tryParse(price) ?? 0) - discount}'
                          : 'Buy – $price',
                      style: const TextStyle(
                        color: _text,
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: _subText, fontFamily: 'Alexandria', fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: _text, fontFamily: 'Alexandria', fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      color: _card,
      child: const Center(
        child: Icon(Icons.shield_outlined, color: _subText, size: 60),
      ),
    );
  }
}
