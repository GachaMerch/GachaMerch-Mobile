import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../utils.dart';

enum _BuyStep { quantity, confirm, loading, success, error }

class BuyDialog extends StatefulWidget {
  final dynamic weapon;
  const BuyDialog({super.key, required this.weapon});

  @override
  State<BuyDialog> createState() => _BuyDialogState();
}

class _BuyDialogState extends State<BuyDialog> {
  _BuyStep _step = _BuyStep.quantity;
  int _quantity = 1;
  String _errorMsg = '';
  int _remainingCoins = 0;

  int get _unitPrice {
    final price = num.tryParse(widget.weapon['Price']?.toString() ?? '') ?? 0;
    final discount =
        num.tryParse(widget.weapon['DiscountAmount']?.toString() ?? '') ?? 0;
    return (price - discount).toInt();
  }

  int get _total => _unitPrice * _quantity;

  Future<void> _executeBuy() async {
    setState(() => _step = _BuyStep.loading);
    try {
      final weaponId =
          int.tryParse(widget.weapon['WeaponId']?.toString() ?? '') ?? 0;
      final result = await OrderService.buyWeapon(
        weaponId: weaponId,
        quantity: _quantity,
      );
      _remainingCoins = (result['remainingCoins'] as num?)?.toInt() ?? 0;
      if (mounted) setState(() => _step = _BuyStep.success);
    } catch (e) {
      _errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) setState(() => _step = _BuyStep.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? const Color(0xFF88888A) : const Color(0xFF8A8A8E);
    final title = widget.weapon['Title']?.toString() ?? 'Unknown';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: _buildContent(
          fieldBg: fieldBg,
          textColor: textColor,
          subText: subText,
          title: title,
        ),
      ),
    );
  }

  Widget _buildContent({
    required Color fieldBg,
    required Color textColor,
    required Color subText,
    required String title,
  }) {
    switch (_step) {
      case _BuyStep.quantity:
        return _quantityContent(
            fieldBg: fieldBg, textColor: textColor, subText: subText, title: title);
      case _BuyStep.confirm:
        return _confirmContent(textColor: textColor, subText: subText, title: title);
      case _BuyStep.loading:
        return _loadingContent(textColor: textColor);
      case _BuyStep.success:
        return _resultContent(
          success: true,
          textColor: textColor,
          subText: subText,
          message: 'Pembelian Berhasil!',
          subtitle: 'Sisa koin: ${formatCoins(_remainingCoins)}',
          onDone: () => Navigator.pop(
            context,
            {'success': true, 'remainingCoins': _remainingCoins},
          ),
        );
      case _BuyStep.error:
        return _resultContent(
          success: false,
          textColor: textColor,
          subText: subText,
          message: 'Pembelian Gagal',
          subtitle: _errorMsg,
          onDone: () => Navigator.pop(context, null),
        );
    }
  }

  Widget _quantityContent({
    required Color fieldBg,
    required Color textColor,
    required Color subText,
    required String title,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: TextStyle(
                color: textColor,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 16),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/icon/coin.png', width: 14, height: 14),
          const SizedBox(width: 4),
          Text('${formatCoins(_unitPrice)} / item',
              style: TextStyle(
                  color: subText, fontFamily: 'Alexandria', fontSize: 13)),
        ]),
        const SizedBox(height: 20),
        Container(
          decoration:
              BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _qtyBtn(
              icon: Icons.remove,
              active: _quantity > 1,
              onTap: () => setState(() => _quantity--),
            ),
            SizedBox(
              width: 60,
              child: Text('$_quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            _qtyBtn(
                icon: Icons.add,
                active: true,
                onTap: () => setState(() => _quantity++)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration:
              BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      color: subText, fontFamily: 'Alexandria', fontSize: 14)),
              Row(children: [
                Image.asset('assets/icon/coin.png', width: 16, height: 16),
                const SizedBox(width: 6),
                Text(formatCoins(_total),
                    style: TextStyle(
                        color: textColor,
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _cancelBtn(subText)),
          const SizedBox(width: 12),
          Expanded(
            child: _goldBtn(
              label: 'Beli',
              onTap: () => setState(() => _step = _BuyStep.confirm),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _confirmContent({
    required Color textColor,
    required Color subText,
    required String title,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD4AF37), size: 48),
        const SizedBox(height: 12),
        Text('Yakin mau beli?',
            style: TextStyle(
                color: textColor,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          '$_quantity× $title\nseharga ${formatCoins(_total)} koin',
          style: TextStyle(
              color: subText, fontFamily: 'Alexandria', fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: _cancelBtn(subText,
                onTap: () => setState(() => _step = _BuyStep.quantity)),
          ),
          const SizedBox(width: 12),
          Expanded(child: _goldBtn(label: 'Ya, Beli', onTap: _executeBuy)),
        ]),
      ],
    );
  }

  Widget _loadingContent({required Color textColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 3),
        const SizedBox(height: 16),
        Text('Memproses...',
            style: TextStyle(
                color: textColor, fontFamily: 'Alexandria', fontSize: 14)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _resultContent({
    required bool success,
    required Color textColor,
    required Color subText,
    required String message,
    required String subtitle,
    required VoidCallback onDone,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          success ? Icons.check_circle_outline : Icons.error_outline,
          color: success ? const Color(0xFF4CAF50) : Colors.redAccent,
          size: 56,
        ),
        const SizedBox(height: 12),
        Text(message,
            style: TextStyle(
                color: textColor,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 16),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle,
            style:
                TextStyle(color: subText, fontFamily: 'Alexandria', fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  success ? const Color(0xFF4CAF50) : Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('OK',
                style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3A3A3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: active ? Colors.white : const Color(0xFF88888A), size: 18),
      ),
    );
  }

  Widget _cancelBtn(Color subText, {VoidCallback? onTap}) {
    return OutlinedButton(
      onPressed: onTap ?? () => Navigator.pop(context, null),
      style: OutlinedButton.styleFrom(
        foregroundColor: subText,
        side: BorderSide(color: subText.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(44),
      ),
      child: const Text('Batal',
          style:
              TextStyle(fontFamily: 'Alexandria', fontWeight: FontWeight.w600)),
    );
  }

  Widget _goldBtn({required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(44),
        elevation: 0,
      ),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.bold,
              fontSize: 14)),
    );
  }
}
