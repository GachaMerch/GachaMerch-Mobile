import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/weapon_service.dart';

const String _mediaBaseUrl = kReleaseMode
    ? 'https://gachamerch-be.drian.my.id'
    : 'http://10.0.2.2:3000';

const Color _bg = Color(0xFF1F1F1F);
const Color _card = Color(0xFF2A2A2A);
const Color _text = Color(0xFFFFFFFF);
const Color _subText = Color(0xFF88888A);

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> _weapons = [];
  bool _isLoadingWeapons = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _bannerPage = 0;
  final ScrollController _scrollController = ScrollController();

  final List<String> _banners = [
    'assets/banner/banner-1.png',
    'assets/banner/banner-1.png',
    'assets/banner/banner-1.png',
    'assets/banner/banner-1.png',
    'assets/banner/banner-1.png',
  ];
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _fetchWeapons();
    _startBannerTimer();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _currentPage < _totalPages) {
        _loadMoreWeapons();
      }
    });
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeapons() async {
    try {
      final result = await WeaponService.getWeapons(page: 1, limit: 8);
      setState(() {
        _weapons = result['weapons'];
        _totalPages = result['totalPages'];
        _currentPage = 1;
        _isLoadingWeapons = false;
      });
    } catch (_) {
      setState(() => _isLoadingWeapons = false);
    }
  }

  Future<void> _loadMoreWeapons() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await WeaponService.getWeapons(page: _currentPage + 1, limit: 8);
      setState(() {
        _weapons.addAll(result['weapons']);
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
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
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildBanner(),
                    const SizedBox(height: 20),
                    _buildNewThisPatch(),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(color: _subText, strokeWidth: 2),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 191,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _banners.length,
                onPageChanged: (i) => setState(() => _bannerPage = i),
                itemBuilder: (_, i) => Image.asset(
                  _banners[i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // dots inside banner
            Positioned(
              bottom: 12,
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
                      color: _bannerPage == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
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

  Widget _buildNewThisPatch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New This Patch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Alexandria',
            color: _text,
          ),
        ),
        const SizedBox(height: 12),
        _isLoadingWeapons
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: _text),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _weapons.length,
                itemBuilder: (_, i) => _buildWeaponCard(_weapons[i]),
              ),
      ],
    );
  }

  Widget _buildWeaponCard(dynamic weapon) {
    final imagePath = weapon['Image'] as String?;
    final imageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? '$_mediaBaseUrl$imagePath'
        : null;
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: _card,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: _subText,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => _weaponDummy(),
              )
            : _weaponDummy(),
      ),
    );
  }

  Widget _weaponDummy() {
    return Container(
      color: _card,
      child: const Center(
        child: Icon(Icons.shield_outlined, color: _subText, size: 40),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon('assets/icon/home-icon.png', 0),
          _navIcon('assets/icon/weapon-icon.png', 1),
          _navProfile(),
          _navIcon('assets/icon/shop-icon.png', 3),
          _navIcon('assets/icon/history-icon.png', 4),
        ],
      ),
    );
  }

  Widget _navIcon(String asset, int index) {
    final selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3A3A3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          asset,
          width: 24,
          height: 24,
          color: selected ? _text : _subText,
        ),
      ),
    );
  }

  Widget _navProfile() {
    final avatarUrl = widget.user['avatar'] as String?;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedIndex == 2 ? _text : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _profileFallback(),
                )
              : _profileFallback(),
        ),
      ),
    );
  }

  Widget _profileFallback() {
    return Container(
      color: _card,
      child: const Icon(Icons.person, color: _subText, size: 28),
    );
  }
}
