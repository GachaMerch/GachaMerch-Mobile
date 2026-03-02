import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/inventory_service.dart';
import 'utils.dart';

const String _mediaBaseUrl = kReleaseMode
    ? 'https://gachamerch-be.drian.my.id'
    : 'http://10.0.2.2:3000';

const Color _subText = Color(0xFF88888A);

enum _SortOption {
  rarityDesc,
  rarityAsc,
  nameAZ,
  nameZA,
  newest,
  oldest,
}

extension _SortLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.rarityDesc: return 'Rarity: High → Low';
      case _SortOption.rarityAsc:  return 'Rarity: Low → High';
      case _SortOption.nameAZ:     return 'Name: A → Z';
      case _SortOption.nameZA:     return 'Name: Z → A';
      case _SortOption.newest:     return 'Newest First';
      case _SortOption.oldest:     return 'Oldest First';
    }
  }
}

class InventoryPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const InventoryPage({super.key, required this.user});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _card => Theme.of(context).colorScheme.surface;
  Color get _text => Theme.of(context).colorScheme.onSurface;

  List<dynamic> _items = [];
  bool _isLoading = true;
  _SortOption _sortOption = _SortOption.rarityDesc;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    try {
      final items = await InventoryService.getInventory();
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _sortedItems {
    final list = List<dynamic>.from(_items);
    list.sort((a, b) {
      final wa = a['weapon'];
      final wb = b['weapon'];
      switch (_sortOption) {
        case _SortOption.rarityDesc:
          return ((wb['Rarity'] as num?) ?? 0)
              .compareTo((wa['Rarity'] as num?) ?? 0);
        case _SortOption.rarityAsc:
          return ((wa['Rarity'] as num?) ?? 0)
              .compareTo((wb['Rarity'] as num?) ?? 0);
        case _SortOption.nameAZ:
          return (wa['Title'] ?? '').toString()
              .compareTo((wb['Title'] ?? '').toString());
        case _SortOption.nameZA:
          return (wb['Title'] ?? '').toString()
              .compareTo((wa['Title'] ?? '').toString());
        case _SortOption.newest:
          final da = DateTime.tryParse(a['acquiredAt']?.toString() ?? '') ?? DateTime(0);
          final db = DateTime.tryParse(b['acquiredAt']?.toString() ?? '') ?? DateTime(0);
          return db.compareTo(da);
        case _SortOption.oldest:
          final da = DateTime.tryParse(a['acquiredAt']?.toString() ?? '') ?? DateTime(0);
          final db = DateTime.tryParse(b['acquiredAt']?.toString() ?? '') ?? DateTime(0);
          return da.compareTo(db);
      }
    });
    return list;
  }

  void _showSortSheet() {
    final cardColor = _card;
    final textColor = _text;
    final currentSort = _sortOption;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      showDragHandle: false,
      elevation: 0,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: ColoredBox(
            color: cardColor,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.asset(
                      'assets/icon/Polygon.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                const Divider(color: Color(0xFF4A4A4A), thickness: 1, height: 1),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Sort by',
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._SortOption.values.map((opt) => _sortTile(opt, currentSort, textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sortTile(_SortOption opt, _SortOption currentSort, Color textColor) {
    final selected = currentSort == opt;
    return InkWell(
      onTap: () {
        setState(() => _sortOption = opt);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                opt.label,
                style: TextStyle(
                  color: selected ? const Color(0xFFD4AF37) : textColor,
                  fontFamily: 'Alexandria',
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: Color(0xFFD4AF37), size: 18),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(dynamic item) {
    final weapon = item['weapon'] as Map<String, dynamic>?;
    if (weapon == null) return;
    final quantity = item['quantity'] as int? ?? 1;
    final cardColor = _card;
    final textColor = _text;
    final imagePath = weapon['Image'] as String? ?? '';
    final imageUrl = imagePath.isNotEmpty ? '$_mediaBaseUrl$imagePath' : null;
    final rarity = num.tryParse(weapon['Rarity']?.toString() ?? '')?.toInt() ?? 0;
    final baseAtk = num.tryParse(weapon['BaseAtk']?.toString() ?? '')?.toInt().toString() ?? '-';
    final subStat = weapon['SubStat']?.toString() ?? '-';
    final subStatValue = weapon['SubStatValue']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      elevation: 0,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: ColoredBox(
            color: cardColor,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.asset('assets/icon/Polygon.png', width: 20, height: 20),
                  ),
                ),
                const Divider(color: Color(0xFF4A4A4A), thickness: 1, height: 1),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weapon['Title']?.toString() ?? '',
                              style: TextStyle(
                                color: textColor,
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Divider(color: Color(0xFF4A4A4A), thickness: 1.5, height: 1),
                            const SizedBox(height: 6),
                            Text(
                              weapon['Type']?.toString() ?? '',
                              style: const TextStyle(
                                color: _subText,
                                fontFamily: 'Alexandria',
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (subStat != '-') ...[
                              _detailStat(subStat, subStatValue, textColor),
                              const SizedBox(height: 12),
                            ],
                            _detailStat('Basic Attack', baseAtk, textColor),
                            const SizedBox(height: 16),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Image.asset(
                                    'assets/icon/star.png',
                                    width: 16,
                                    height: 16,
                                    color: i < rarity ? const Color(0xFFFFD700) : _subText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) => progress == null
                                      ? child
                                      : Container(
                                          color: cardColor,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: _subText,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                  errorBuilder: (_, __, ___) => _weaponDummy(cardColor),
                                )
                              : _weaponDummy(cardColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF4A4A4A), thickness: 1),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weapon['PassiveName'] != null && weapon['PassiveName'] != '-') ...[
                        Text(
                          weapon['PassiveName'].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Owned: x$quantity',
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'Alexandria',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String? value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _subText, fontFamily: 'Alexandria', fontSize: 12),
        ),
        if (value != null) ...[
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedItems;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSortRow()),
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: _subText),
                      ),
                    )
                  else if (_items.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => GestureDetector(
                            onTap: () => _showItemDetail(sorted[i]),
                            child: _buildCard(sorted[i]),
                          ),
                          childCount: sorted.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final raw = widget.user['coin'];
    final coin = raw is num ? raw : num.tryParse(raw?.toString() ?? '') ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            'Inventory',
            style: TextStyle(
              color: _text,
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const Spacer(),
          // coin badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatCoins(coin),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset('assets/icon/coin.png', width: 16, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _showSortSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _subText.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    color: _text,
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: _text, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    final weapon = item['weapon'];
    if (weapon == null) return const SizedBox.shrink();
    final quantity = item['quantity'] as int? ?? 1;
    final imagePath = weapon['Image'] as String?;
    final imageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? '$_mediaBaseUrl$imagePath'
        : null;
    final rarity = (weapon['Rarity'] as num?)?.toInt() ?? 0;
    final cardColor = _card;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: cardColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: _subText,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => _weaponDummy(cardColor),
                  )
                : _weaponDummy(cardColor),
          ),
        ),
        // gradient overlay bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 48,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
        ),
        // rarity stars bottom-left
        Positioned(
          bottom: 8,
          left: 8,
          child: Row(
            children: List.generate(
              rarity.clamp(0, 5),
              (_) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Image.asset(
                  'assets/icon/star.png',
                  width: 12,
                  height: 12,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
        ),
        // quantity badge top-right
        if (quantity > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'x$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Alexandria',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _weaponDummy(Color cardColor) {
    return Container(
      color: cardColor,
      child: const Center(
        child: Icon(Icons.shield_outlined, color: _subText, size: 40),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, color: _subText, size: 64),
          const SizedBox(height: 16),
          Text(
            'Inventory kosong',
            style: TextStyle(
              color: _text,
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Beli senjata di Home untuk mengisi inventory',
            style: TextStyle(
              color: _subText,
              fontFamily: 'Alexandria',
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = widget.user['avatar'] as String?;

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
          Expanded(
            child: _navItem(
              asset: 'assets/icon/home-icon.png',
              selected: false,
              onTap: () => Navigator.pop(context),
            ),
          ),
          // weapon — active
          Expanded(
            child: SizedBox(
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icon/weapon-icon.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // profile avatar
          Expanded(
            child: SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarFallback(),
                          )
                        : _avatarFallback(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _navItem(asset: 'assets/icon/shop-icon.png', selected: false),
          ),
          Expanded(
            child: _navItem(asset: 'assets/icon/history-icon.png', selected: false),
          ),
        ],
      ),
    );
  }

  Widget _navItem({required String asset, required bool selected, VoidCallback? onTap}) {
    return SizedBox(
      height: 48,
      child: GestureDetector(
        onTap: onTap,
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
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF3A3A3A),
      child: const Icon(Icons.person, color: _subText, size: 20),
    );
  }
}
