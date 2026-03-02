import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/weapon_service.dart';

const String _mediaBase = kReleaseMode
    ? 'https://gachamerch-be.drian.my.id'
    : 'http://10.0.2.2:3000';

const Color _sub  = Color(0xFF88888A);
const Color _gold = Color(0xFFD4AF37);

enum _Step { detail, update, loading, success, error }

class WeaponAdminSheet extends StatefulWidget {
  final dynamic weapon;
  final VoidCallback? onChanged;
  const WeaponAdminSheet({super.key, required this.weapon, this.onChanged});

  @override
  State<WeaponAdminSheet> createState() => _WeaponAdminSheetState();
}

class _WeaponAdminSheetState extends State<WeaponAdminSheet> {
  final _sheetCtrl = DraggableScrollableController();

  _Step  _step     = _Step.detail;
  bool   _isDelete = false;
  String _errMsg   = '';

  late final TextEditingController _titleCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _baseAtkCtrl;
  late final TextEditingController _subStatCtrl;
  late final TextEditingController _passiveNameCtrl;
  late final TextEditingController _descCtrl;

  String _type   = 'Sword';
  int    _rarity = 3;
  File?  _imageFile;

  static const _types = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];
  static const _rarityNames = {
    1: 'Common', 2: 'Uncommon', 3: 'Rare', 4: 'Epic', 5: 'Legendary',
  };

  String _numStr(dynamic v) {
    if (v == null) return '';
    final n = num.tryParse(v.toString());
    if (n == null) return '';
    return n % 1 == 0 ? n.toInt().toString() : n.toString();
  }

  @override
  void initState() {
    super.initState();
    final w = widget.weapon;
    _titleCtrl       = TextEditingController(text: w['Title']?.toString() ?? '');
    _priceCtrl       = TextEditingController(text: _numStr(w['Price']));
    _discountCtrl    = TextEditingController(text: _numStr(w['DiscountAmount']));
    _baseAtkCtrl     = TextEditingController(text: _numStr(w['BaseAtk']));
    _subStatCtrl     = TextEditingController(text: w['SubStat']?.toString() ?? '');
    _passiveNameCtrl = TextEditingController(text: w['PassiveName']?.toString() ?? '');
    _descCtrl        = TextEditingController(text: w['PassiveDesc']?.toString() ?? '');
    final t = w['Type']?.toString() ?? 'Sword';
    _type   = _types.contains(t) ? t : 'Sword';
    _rarity = (w['Rarity'] as num?)?.toInt().clamp(1, 5) ?? 3;
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _baseAtkCtrl.dispose();
    _subStatCtrl.dispose();
    _passiveNameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _goToUpdate() {
    setState(() => _step = _Step.update);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sheetCtrl.isAttached) {
        _sheetCtrl.animateTo(
          0.93,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConfirm(Color textColor, Color subText) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Weapon?',
            style: TextStyle(
              color: textColor, fontFamily: 'Alexandria',
              fontWeight: FontWeight.bold, fontSize: 16,
            )),
        content: Text(
          '"${widget.weapon['Title']}" akan dihapus secara permanen.',
          style: TextStyle(color: subText, fontFamily: 'Alexandria', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: TextStyle(fontFamily: 'Alexandria', color: subText)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _executeRemove(); },
            child: const Text('Hapus',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                )),
          ),
        ],
      ),
    );
  }

  void _showAlert(String msg, Color textColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Periksa Input',
            style: TextStyle(
              color: textColor, fontFamily: 'Alexandria',
              fontWeight: FontWeight.bold, fontSize: 16,
            )),
        content: Text(msg,
            style: const TextStyle(fontFamily: 'Alexandria', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w600,
                  color: _gold,
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _executeRemove() async {
    setState(() { _isDelete = true; _step = _Step.loading; });
    try {
      final id = int.tryParse(widget.weapon['WeaponId']?.toString() ?? '') ?? 0;
      await WeaponService.deleteWeapon(id);
      if (mounted) setState(() => _step = _Step.success);
    } catch (e) {
      _errMsg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) setState(() => _step = _Step.error);
    }
  }

  Future<void> _executeUpdate(Color textColor) async {
    final title     = _titleCtrl.text.trim();
    final priceText = _priceCtrl.text.trim();
    final atkText   = _baseAtkCtrl.text.trim();
    final discText  = _discountCtrl.text.trim();
    final price     = double.tryParse(priceText);
    final baseAtk   = double.tryParse(atkText);
    final discount  = discText.isEmpty ? 0.0 : double.tryParse(discText);

    if (title.isEmpty) {
      _showAlert('Item\'s Name tidak boleh kosong.', textColor); return;
    }
    if (priceText.isEmpty || price == null) {
      _showAlert('Price harus diisi dengan angka yang valid.', textColor); return;
    }
    if (price <= 0) {
      _showAlert('Price harus lebih dari 0.', textColor); return;
    }
    if (atkText.isEmpty || baseAtk == null) {
      _showAlert('Base ATK harus diisi dengan angka yang valid.', textColor); return;
    }
    if (baseAtk <= 0) {
      _showAlert('Base ATK harus lebih dari 0.', textColor); return;
    }
    if (discount == null) {
      _showAlert('Discount harus berupa angka yang valid.', textColor); return;
    }
    if (discount < 0 || discount >= price) {
      _showAlert('Discount harus antara 0 dan kurang dari Price.', textColor); return;
    }

    setState(() { _isDelete = false; _step = _Step.loading; });
    try {
      final id = int.tryParse(widget.weapon['WeaponId']?.toString() ?? '') ?? 0;
      await WeaponService.updateWeapon(
        weaponId:    id,
        title:       title,
        type:        _type,
        rarity:      _rarity,
        price:       price,
        discount:    discount,
        baseAtk:     baseAtk,
        subStat:     _subStatCtrl.text.trim(),
        passiveName: _passiveNameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageFile:   _imageFile,
      );
      if (mounted) setState(() => _step = _Step.success);
    } catch (e) {
      _errMsg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) setState(() => _step = _Step.error);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final sheetBg   = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final fieldBg   = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText   = isDark ? const Color(0xFF88888A) : const Color(0xFF8A8A8E);

    return DraggableScrollableSheet(
      controller: _sheetCtrl,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ColoredBox(
          color: sheetBg,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildBody(
              key: ValueKey(_step),
              ctrl: ctrl,
              sheetBg: sheetBg,
              fieldBg: fieldBg,
              textColor: textColor,
              subText: subText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required Key key,
    required ScrollController ctrl,
    required Color sheetBg,
    required Color fieldBg,
    required Color textColor,
    required Color subText,
  }) {
    switch (_step) {
      case _Step.detail:
        return _buildDetail(key: key, ctrl: ctrl, sheetBg: sheetBg, textColor: textColor, subText: subText);
      case _Step.update:
        return _buildUpdateForm(key: key, ctrl: ctrl, fieldBg: fieldBg, textColor: textColor, subText: subText);
      case _Step.loading:
        return _buildLoading(key: key, ctrl: ctrl, textColor: textColor);
      case _Step.success:
      case _Step.error:
        return _buildResult(key: key, ctrl: ctrl, textColor: textColor, subText: subText);
    }
  }

  // ── Drag handle ──────────────────────────────────────────────────────────
  Widget _handle() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Image.asset('assets/icon/Polygon.png', width: 20, height: 20),
        ),
      ),
      const Divider(color: Color(0xFF4A4A4A), thickness: 1, height: 1),
    ],
  );

  // ── Detail view ──────────────────────────────────────────────────────────
  Widget _buildDetail({
    required Key key,
    required ScrollController ctrl,
    required Color sheetBg,
    required Color textColor,
    required Color subText,
  }) {
    final w         = widget.weapon;
    final imagePath = w['Image'] as String? ?? '';
    final imageUrl  = imagePath.isNotEmpty ? '$_mediaBase$imagePath' : null;
    final rarity    = (w['Rarity'] as num?)?.toInt() ?? 0;
    final baseAtk   = _numStr(w['BaseAtk']);
    final subStat   = w['SubStat']?.toString() ?? '';

    return ListView(
      key: key,
      controller: ctrl,
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _handle(),
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
                    Text(w['Title']?.toString() ?? '',
                        style: TextStyle(
                          color: textColor, fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold, fontSize: 20,
                        )),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xFF4A4A4A), thickness: 1.5, height: 1),
                    const SizedBox(height: 6),
                    Text(w['Type']?.toString() ?? '',
                        style: const TextStyle(
                          color: _sub, fontFamily: 'Alexandria', fontSize: 13,
                        )),
                    const SizedBox(height: 16),
                    if (subStat.isNotEmpty) ...[
                      _statBlock('Sub Stat', subStat, textColor),
                      const SizedBox(height: 12),
                    ],
                    _statBlock('Basic Attack', baseAtk, textColor),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(5, (i) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Image.asset('assets/icon/star.png',
                            width: 16, height: 16,
                            color: i < rarity ? const Color(0xFFFFD700) : _sub),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120, height: 120,
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _dummy(sheetBg))
                      : _dummy(sheetBg),
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
              if ((w['PassiveName']?.toString() ?? '').isNotEmpty) ...[
                Text(w['PassiveName'].toString(),
                    style: TextStyle(
                      color: textColor, fontFamily: 'Alexandria',
                      fontWeight: FontWeight.w600, fontSize: 14,
                    )),
                const SizedBox(height: 6),
              ],
              if ((w['PassiveDesc']?.toString() ?? '').isNotEmpty)
                Text(w['PassiveDesc'].toString(),
                    style: const TextStyle(
                      color: _sub, fontFamily: 'Alexandria',
                      fontSize: 13, height: 1.5,
                    )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _goToUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3A3A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Update',
                      style: TextStyle(fontFamily: 'Alexandria', fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () => _showConfirm(textColor, subText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Remove',
                      style: TextStyle(fontFamily: 'Alexandria', fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Update form ──────────────────────────────────────────────────────────
  Widget _buildUpdateForm({
    required Key key,
    required ScrollController ctrl,
    required Color fieldBg,
    required Color textColor,
    required Color subText,
  }) {
    final border = subText.withValues(alpha: 0.2);

    return ListView(
      key: key,
      controller: ctrl,
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _handle(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Weapon',
                  style: TextStyle(
                    color: textColor, fontFamily: 'Alexandria',
                    fontWeight: FontWeight.bold, fontSize: 20,
                  )),
              const SizedBox(height: 20),

              // ── Row 1: Image + Name / Category / BaseATK ─────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : _existingImagePreview(fieldBg, subText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Item's name", textColor),
                        const SizedBox(height: 6),
                        _field(ctrl: _titleCtrl, hint: 'e.g. Hunter Strike',
                            fieldBg: fieldBg, textColor: textColor, subText: subText),
                        const SizedBox(height: 10),
                        _label('Category', textColor),
                        const SizedBox(height: 6),
                        _dropdown(value: _type, items: _types,
                            fieldBg: fieldBg, textColor: textColor, subText: subText,
                            onChanged: (v) => setState(() => _type = v!)),
                        const SizedBox(height: 10),
                        _label('Base Atk', textColor),
                        const SizedBox(height: 6),
                        _field(ctrl: _baseAtkCtrl, hint: '0',
                            fieldBg: fieldBg, textColor: textColor, subText: subText,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Row 2: Price + Statistic ──────────────────────────────────
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Price', textColor),
                      const SizedBox(height: 6),
                      _field(ctrl: _priceCtrl, hint: '0',
                          fieldBg: fieldBg, textColor: textColor, subText: subText,
                          keyboardType: TextInputType.number,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 6),
                            child: Image.asset('assets/icon/coin.png', width: 16, height: 16),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Statistic', textColor),
                      const SizedBox(height: 6),
                      _field(ctrl: _subStatCtrl, hint: 'e.g. Crit Rate',
                          fieldBg: fieldBg, textColor: textColor, subText: subText),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Row 3: Rarity + Passive Name ──────────────────────────────
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Rarity', textColor),
                      const SizedBox(height: 6),
                      _rarityDropdown(fieldBg: fieldBg, textColor: textColor, subText: subText),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Passive Name', textColor),
                      const SizedBox(height: 6),
                      _field(ctrl: _passiveNameCtrl, hint: "e.g. Falcon's Defiance",
                          fieldBg: fieldBg, textColor: textColor, subText: subText),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Discount ──────────────────────────────────────────────────
              _label('Discount', textColor),
              const SizedBox(height: 6),
              _field(ctrl: _discountCtrl, hint: '0',
                  fieldBg: fieldBg, textColor: textColor, subText: subText,
                  keyboardType: TextInputType.number,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: Image.asset('assets/icon/coin.png', width: 16, height: 16),
                  )),
              const SizedBox(height: 16),

              // ── Passive description ───────────────────────────────────────
              _label('Passive description', textColor),
              const SizedBox(height: 6),
              _field(ctrl: _descCtrl, hint: 'Weapon passive description...',
                  fieldBg: fieldBg, textColor: textColor, subText: subText, maxLines: 4),
              const SizedBox(height: 24),

              // ── Save Changes ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () => _executeUpdate(textColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3A3A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(fontFamily: 'Alexandria', fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading({required Key key, required ScrollController ctrl, required Color textColor}) {
    return ListView(
      key: key, controller: ctrl,
      children: [
        _handle(),
        const SizedBox(height: 60),
        const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 3)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            _isDelete ? 'Menghapus...' : 'Menyimpan...',
            style: TextStyle(color: textColor, fontFamily: 'Alexandria', fontSize: 14),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // ── Success / Error ───────────────────────────────────────────────────────
  Widget _buildResult({
    required Key key,
    required ScrollController ctrl,
    required Color textColor,
    required Color subText,
  }) {
    final isSuccess = _step == _Step.success;
    final message = isSuccess
        ? (_isDelete ? 'Weapon Dihapus!'    : 'Weapon Diperbarui!')
        : (_isDelete ? 'Gagal Menghapus'    : 'Gagal Memperbarui');
    final subtitle = isSuccess
        ? (_isDelete
            ? '"${widget.weapon['Title']}" berhasil dihapus.'
            : '"${widget.weapon['Title']}" berhasil diperbarui.')
        : _errMsg;

    return ListView(
      key: key, controller: ctrl,
      children: [
        _handle(),
        const SizedBox(height: 40),
        Center(
          child: Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? const Color(0xFF4CAF50) : Colors.redAccent,
            size: 64,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(message,
              style: TextStyle(
                color: textColor, fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold, fontSize: 18,
              )),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(subtitle,
                style: TextStyle(color: subText, fontFamily: 'Alexandria', fontSize: 13),
                textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (isSuccess) {
                  Navigator.pop(context);
                  widget.onChanged?.call();
                } else {
                  setState(() => _step = _isDelete ? _Step.detail : _Step.update);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? const Color(0xFF4CAF50) : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                isSuccess ? 'OK' : 'Coba Lagi',
                style: const TextStyle(
                  fontFamily: 'Alexandria', fontWeight: FontWeight.bold, fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _existingImagePreview(Color fieldBg, Color subText) {
    final imagePath = widget.weapon['Image'] as String? ?? '';
    final imageUrl  = imagePath.isNotEmpty ? '$_mediaBase$imagePath' : null;
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgPlaceholder(subText)),
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Icon(Icons.edit, color: Colors.white, size: 22),
            ),
          ],
        ),
      );
    }
    return _imgPlaceholder(subText);
  }

  Widget _imgPlaceholder(Color subText) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_a_photo, color: subText, size: 26),
      const SizedBox(height: 4),
      Text('Image', style: TextStyle(color: subText, fontFamily: 'Alexandria', fontSize: 11)),
    ],
  );

  Widget _dummy(Color bg) => Container(
    color: bg,
    child: const Center(child: Icon(Icons.shield_outlined, color: _sub, size: 32)),
  );

  Widget _statBlock(String label, String value, Color textColor) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: _sub, fontFamily: 'Alexandria', fontSize: 12)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(
          color: textColor, fontFamily: 'Alexandria',
          fontWeight: FontWeight.w600, fontSize: 16)),
    ],
  );

  Widget _label(String text, Color color) => Text(text,
      style: TextStyle(
        color: color, fontFamily: 'Alexandria',
        fontSize: 12, fontWeight: FontWeight.w600,
      ));

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required Color fieldBg,
    required Color textColor,
    required Color subText,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? prefix,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: subText.withValues(alpha: 0.2)),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: textColor, fontFamily: 'Alexandria', fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: subText, fontSize: 13),
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: InputBorder.none,
          ),
        ),
      );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Color fieldBg,
    required Color textColor,
    required Color subText,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: subText.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: fieldBg,
            style: TextStyle(color: textColor, fontFamily: 'Alexandria', fontSize: 13),
            icon: Icon(Icons.expand_more, color: subText, size: 18),
            items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _rarityDropdown({
    required Color fieldBg,
    required Color textColor,
    required Color subText,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: subText.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _rarity,
            isExpanded: true,
            dropdownColor: fieldBg,
            style: TextStyle(color: textColor, fontFamily: 'Alexandria', fontSize: 13),
            icon: Icon(Icons.expand_more, color: subText, size: 18),
            items: _rarityNames.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _rarity = v ?? _rarity),
          ),
        ),
      );
}
