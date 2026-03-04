import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/shop_service.dart';
import 'services/auth_service.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/buy_dialog.dart';
import 'widgets/weapon_admin_sheet.dart';
import 'InventoryPage.dart';
import 'ProfilePage.dart';
import 'NotificationPage.dart';
import 'utils/format.dart';

const String _mediaBaseUrl = kReleaseMode
    ? 'https://gachamerch-be.drian.my.id'
    : 'http://10.0.2.2:3000';

const Color _subText = Color(0xFF88888A);
const Color _gold = Color(0xFFD4AF37);

enum _ShopSort { priceAsc, priceDesc, rarityDesc, rarityAsc }

extension _ShopSortLabel on _ShopSort {
  String get label {
    switch (this) {
      case _ShopSort.priceAsc:   return 'Price: Low → High';
      case _ShopSort.priceDesc:  return 'Price: High → Low';
      case _ShopSort.rarityDesc: return 'Rarity: High → Low';
      case _ShopSort.rarityAsc:  return 'Rarity: Low → High';
    }
  }
}

class ShopPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ShopPage({super.key, required this.user});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Color get _bg   => Theme.of(context).scaffoldBackgroundColor;
  Color get _card => Theme.of(context).colorScheme.surface;
  Color get _text => Theme.of(context).colorScheme.onSurface;
  bool  get _isAdmin => _user['roleId'] == 1;

  Map<String, dynamic> _user = {};
  List<dynamic> _limitedItems = [];
  List<dynamic> _legendary   = [];
  bool _isLoading = true;
  _ShopSort _sort = _ShopSort.rarityDesc;

  // banner
  final List<String> _banners = [
    'assets/banner/banner-1.png',
    'assets/banner/banner-2.png',
    'assets/banner/banner-3.png',
    'assets/banner/banner-4.png',
    'assets/banner/banner-5.png',
  ];
  int _bannerPage = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // category page view
  int _categoryIndex = 0;
  final PageController _categoryController = PageController();

  static const List<String> _categoryLabels = [
    'Limited Items',
    'Legendary',
  ];

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user);
    _fetchShop();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_bannerPage + 1) % _banners.length;
      setState(() => _bannerPage = next);
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _refreshUser() async {
    try {
      final fresh = await AuthService.getMe();
      if (mounted) setState(() => _user = {..._user, ...fresh});
    } catch (_) {}
  }

  Future<void> _refresh() => Future.wait([_fetchShop(), _refreshUser()]);

  Future<void> _fetchShop() async {
    try {
      final data = await ShopService.getShopItems();
      if (mounted) {
        setState(() {
          _limitedItems = List<dynamic>.from(data['limitedItems'] ?? []);
          _legendary    = List<dynamic>.from(data['legendary']    ?? []);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _sorted(List<dynamic> list) {
    final l = List<dynamic>.from(list);
    l.sort((a, b) {
      switch (_sort) {
        case _ShopSort.priceAsc:
          return (num.tryParse(a['Price']?.toString() ?? '') ?? 0)
              .compareTo(num.tryParse(b['Price']?.toString() ?? '') ?? 0);
        case _ShopSort.priceDesc:
          return (num.tryParse(b['Price']?.toString() ?? '') ?? 0)
              .compareTo(num.tryParse(a['Price']?.toString() ?? '') ?? 0);
        case _ShopSort.rarityDesc:
          return (num.tryParse(b['Rarity']?.toString() ?? '') ?? 0)
              .compareTo(num.tryParse(a['Rarity']?.toString() ?? '') ?? 0);
        case _ShopSort.rarityAsc:
          return (num.tryParse(a['Rarity']?.toString() ?? '') ?? 0)
              .compareTo(num.tryParse(b['Rarity']?.toString() ?? '') ?? 0);
      }
    });
    return l;
  }

  void _showSortSheet() {
    final cardColor = _card;
    final textColor = _text;
    final currentSort = _sort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      elevation: 0,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.38,
        minChildSize: 0.25,
        maxChildSize: 0.5,
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
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF88888A),
                        borderRadius: BorderRadius.circular(2),
                      ),
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
                ..._ShopSort.values.map((opt) {
                  final selected = currentSort == opt;
                  return InkWell(
                    onTap: () {
                      setState(() => _sort = opt);
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
                                color: selected ? _gold : textColor,
                                fontFamily: 'Alexandria',
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check, color: _gold, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWeaponDetail(dynamic weapon) {
    final cardColor = _card;
    final textColor = _text;
    final imagePath = weapon['Image'] as String? ?? '';
    final imageUrl  = imagePath.isNotEmpty ? '$_mediaBaseUrl$imagePath' : null;
    final rarity    = num.tryParse(weapon['Rarity']?.toString() ?? '')?.toInt() ?? 0;
    final price     = num.tryParse(weapon['Price']?.toString() ?? '')?.toInt() ?? 0;
    final discount  = num.tryParse(weapon['DiscountAmount']?.toString() ?? '')?.toInt() ?? 0;
    final finalPrice = price - discount;
    final baseAtk   = num.tryParse(weapon['BaseAtk']?.toString() ?? '')?.toInt().toString() ?? '-';
    final subStat   = weapon['SubStat']?.toString() ?? '-';

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
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF88888A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
                              _detailStat(subStat, null, textColor),
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
                                      : Container(color: cardColor, child: const Center(child: CircularProgressIndicator(color: _subText, strokeWidth: 2))),
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
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showBuyFlow(weapon);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A3A3A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (discount > 0) ...[
                                  Text(
                                    '$price',
                                    style: const TextStyle(
                                      color: _subText,
                                      fontFamily: 'Alexandria',
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: _subText,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Image.asset('assets/icon/coin.png', width: 18, height: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '$finalPrice',
                                  style: TextStyle(
                                    color: discount > 0 ? _gold : textColor,
                                    fontFamily: 'Alexandria',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
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
        Text(label, style: const TextStyle(color: _subText, fontFamily: 'Alexandria', fontSize: 12)),
        if (value != null) ...[
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: textColor, fontFamily: 'Alexandria', fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ],
    );
  }

  void _showAdminSheet(dynamic weapon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      elevation: 0,
      builder: (_) => WeaponAdminSheet(
        weapon: weapon,
        onChanged: _fetchShop,
      ),
    );
  }

  Future<void> _showBuyFlow(dynamic weapon) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BuyDialog(weapon: weapon),
    );
    if (result == null || !mounted) return;
    if (result['success'] == true) {
      final remaining = result['remainingCoins'] as int?;
      if (remaining != null) setState(() => _user = {..._user, 'coin': remaining});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _subText))
                  : Column(
                      children: [
                        // header
                        _buildHeader(),
                        // banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildBanner(),
                        ),
                        const SizedBox(height: 16),
                        // sort row
                        _buildSortRow(),
                        const SizedBox(height: 12),
                        // category tabs
                        _buildCategoryTabs(),
                        const SizedBox(height: 12),
                        // category page view
                        Expanded(child: _buildCategoryPageView()),
                      ],
                    ),
            ),
            AppBottomNav(
              activeTab: NavTab.shop,
              avatarUrl: _user['avatar'] as String?,
              onTap: (tab) {
                if (tab == NavTab.home) {
                  Navigator.pop(context);
                } else if (tab == NavTab.inventory) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => InventoryPage(user: _user)),
                  );
                } else if (tab == NavTab.profile) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage(user: _user)),
                  );
                } else if (tab == NavTab.history) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationPage(user: _user)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final raw  = _user['coin'];
    final coin = raw is num ? raw : num.tryParse(raw?.toString() ?? '') ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Text(
            "Player's Top Picks",
            style: TextStyle(
              color: _text,
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const Spacer(),
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

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _banners.length,
                onPageChanged: (i) => setState(() => _bannerPage = i),
                itemBuilder: (_, i) => Image.asset(_banners[i], fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _bannerPage == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _bannerPage == i ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  style: TextStyle(color: _text, fontFamily: 'Alexandria', fontSize: 13, fontWeight: FontWeight.w500),
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

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categoryLabels.length,
        itemBuilder: (_, i) {
          final selected = _categoryIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() => _categoryIndex = i);
              _categoryController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _gold : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _gold : _subText.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _categoryLabels[i],
                style: TextStyle(
                  color: selected ? Colors.black : _subText,
                  fontFamily: 'Alexandria',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryPageView() {
    final pages = [
      _sorted(_limitedItems),
      _sorted(_legendary),
    ];

    return PageView.builder(
      controller: _categoryController,
      onPageChanged: (i) => setState(() => _categoryIndex = i),
      itemCount: pages.length,
      itemBuilder: (_, i) {
        final weapons = pages[i];
        return RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.white,
          backgroundColor: const Color(0xFF3A3A3A),
          child: weapons.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [SizedBox(height: 300, child: _buildEmpty())],
                )
              : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: weapons.length,
                  itemBuilder: (_, j) => GestureDetector(
                    onTap: () => _showWeaponDetail(weapons[j]),
                    child: _buildCard(weapons[j], isAdmin: _isAdmin),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCard(dynamic weapon, {bool isAdmin = false}) {
    final imagePath = weapon['Image'] as String?;
    final imageUrl  = (imagePath != null && imagePath.isNotEmpty) ? '$_mediaBaseUrl$imagePath' : null;
    final price     = num.tryParse(weapon['Price']?.toString() ?? '')?.toInt() ?? 0;
    final discount  = num.tryParse(weapon['DiscountAmount']?.toString() ?? '')?.toInt() ?? 0;
    final finalPrice = price - discount;
    final cardColor = _card;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(color: cardColor, child: const Center(child: CircularProgressIndicator(color: _subText, strokeWidth: 2))),
                    errorBuilder: (_, __, ___) => _weaponDummy(cardColor),
                  )
                : _weaponDummy(cardColor),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 0, height: 52,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 6, left: 6, right: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon/coin.png', width: 12, height: 12),
              const SizedBox(width: 3),
              if (discount > 0) ...[
                Text(
                  '$price',
                  style: const TextStyle(
                    color: _subText,
                    fontFamily: 'Alexandria',
                    fontSize: 9,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _subText,
                  ),
                ),
                const SizedBox(width: 3),
                Text('$finalPrice', style: const TextStyle(color: _gold, fontFamily: 'Alexandria', fontWeight: FontWeight.bold, fontSize: 11)),
              ] else
                Text('$finalPrice', style: const TextStyle(color: Colors.white, fontFamily: 'Alexandria', fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ),
        if (discount > 0)
          Positioned(
            top: 6, left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)),
              child: Text('-$discount', style: const TextStyle(color: Colors.white, fontFamily: 'Alexandria', fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
        if (isAdmin)
          Positioned(
            top: 6, right: 6,
            child: GestureDetector(
              onTap: () => _showAdminSheet(weapon),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_horiz, color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _weaponDummy(Color cardColor) {
    return Container(
      color: cardColor,
      child: const Center(child: Icon(Icons.shield_outlined, color: _subText, size: 32)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, color: _subText, size: 64),
          const SizedBox(height: 16),
          Text(
            'Tidak ada item',
            style: TextStyle(color: _text, fontFamily: 'Alexandria', fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
