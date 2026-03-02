import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'widgets/app_bottom_nav.dart';
import 'InventoryPage.dart';
import 'ProfilePage.dart';
import 'ShopPage.dart';

const Color _subText = Color(0xFF88888A);

class NotificationPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const NotificationPage({super.key, required this.user});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Color get _bg   => Theme.of(context).scaffoldBackgroundColor;
  Color get _card => Theme.of(context).colorScheme.surface;
  Color get _text => Theme.of(context).colorScheme.onSurface;

  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await NotificationService.getNotifications();
      if (mounted) setState(() { _notifications = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Groups notifications by date. Returns list of {date, items}.
  List<Map<String, dynamic>> _grouped() {
    final Map<String, List<dynamic>> map = {};
    for (final n in _notifications) {
      final published = DateTime.tryParse(n['PublishedAt']?.toString() ?? '') ?? DateTime.now();
      final key = _dateKey(published);
      map.putIfAbsent(key, () => []).add(n);
    }
    // Sort groups by date descending
    final entries = map.entries.toList()
      ..sort((a, b) {
        final da = _parseKey(a.key);
        final db = _parseKey(b.key);
        return db.compareTo(da);
      });
    return entries.map((e) => {'date': e.key, 'items': e.value}).toList();
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return '__today__';
    if (d == yesterday) return '__yesterday__';
    return dt.toIso8601String().substring(0, 10); // yyyy-MM-dd
  }

  DateTime _parseKey(String key) {
    if (key == '__today__') return DateTime.now();
    if (key == '__yesterday__') return DateTime.now().subtract(const Duration(days: 1));
    return DateTime.tryParse(key) ?? DateTime(2000);
  }

  String _dateLabel(String key) {
    if (key == '__today__') return 'Today';
    if (key == '__yesterday__') return 'Yesterday';
    final dt = DateTime.tryParse(key);
    if (dt == null) return key;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _relativeTime(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? '1 hr ago' : '${diff.inHours} hrs ago';
    }
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).round();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    final years = (diff.inDays / 365).round();
    return years == 1 ? '1 year ago' : '$years years ago';
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
                  : _buildBody(),
            ),
            AppBottomNav(
              activeTab: NavTab.history,
              avatarUrl: widget.user['avatar'] as String?,
              onTap: (tab) {
                if (tab == NavTab.home) {
                  Navigator.pop(context);
                } else if (tab == NavTab.inventory) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => InventoryPage(user: widget.user)),
                  );
                } else if (tab == NavTab.profile) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage(user: widget.user)),
                  );
                } else if (tab == NavTab.shop) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ShopPage(user: widget.user)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final groups = _grouped();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                color: _text,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
        ),
        if (groups.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none_outlined, color: _subText, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: _text, fontFamily: 'Alexandria', fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          for (final group in groups) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  _dateLabel(group['date'] as String),
                  style: TextStyle(
                    color: _text,
                    fontFamily: 'Alexandria',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final item = (group['items'] as List)[i];
                  return _buildCard(item);
                },
                childCount: (group['items'] as List).length,
              ),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }

  Widget _buildCard(dynamic item) {
    final cardColor = _card;
    final textColor = _text;
    final title   = item['Title']?.toString() ?? '';
    final content = item['Content']?.toString() ?? '';
    final relTime = _relativeTime(item['PublishedAt']?.toString());
    final type    = item['Type']?.toString() ?? 'update';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _typeChip(type),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _subText,
                fontFamily: 'Alexandria',
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                relTime,
                style: const TextStyle(
                  color: _subText,
                  fontFamily: 'Alexandria',
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    final label = switch (type) {
      'maintenance' => 'Maintenance',
      'event'       => 'Event',
      _             => 'Update',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _subText,
          fontFamily: 'Alexandria',
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
