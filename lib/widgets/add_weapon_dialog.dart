import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/weapon_service.dart';

class AddWeaponSheet extends StatefulWidget {
  final VoidCallback? onCreated;
  const AddWeaponSheet({super.key, this.onCreated});

  @override
  State<AddWeaponSheet> createState() => _AddWeaponSheetState();
}

class _AddWeaponSheetState extends State<AddWeaponSheet> {
  final _titleCtrl       = TextEditingController();
  final _priceCtrl       = TextEditingController();
  final _discountCtrl    = TextEditingController();
  final _baseAtkCtrl     = TextEditingController();
  final _subStatCtrl     = TextEditingController();
  final _passiveNameCtrl = TextEditingController();
  final _descCtrl        = TextEditingController();

  String _type      = 'Sword';
  int    _rarity    = 3;
  File?  _imageFile;
  bool   _isLoading = false;

  static const _types = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];

  @override
  void dispose() {
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
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Periksa Input',
          style: TextStyle(fontFamily: 'Alexandria', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Alexandria', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.w600,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final title   = _titleCtrl.text.trim();
    final priceText   = _priceCtrl.text.trim();
    final baseAtkText = _baseAtkCtrl.text.trim();
    final discountText = _discountCtrl.text.trim();
    final price   = double.tryParse(priceText);
    final baseAtk = double.tryParse(baseAtkText);
    final discount = discountText.isEmpty ? 0.0 : double.tryParse(discountText);

    if (_imageFile == null) {
      _showAlert('Gambar weapon harus dipilih.');
      return;
    }
    if (title.isEmpty) {
      _showAlert('Item\'s Name tidak boleh kosong.');
      return;
    }
    if (priceText.isEmpty || price == null) {
      _showAlert('Price harus diisi dengan angka yang valid.');
      return;
    }
    if (price <= 0) {
      _showAlert('Price harus lebih dari 0.');
      return;
    }
    if (baseAtkText.isEmpty || baseAtk == null) {
      _showAlert('Base ATK harus diisi dengan angka yang valid.');
      return;
    }
    if (baseAtk <= 0) {
      _showAlert('Base ATK harus lebih dari 0.');
      return;
    }
    if (discount == null) {
      _showAlert('Discount harus berupa angka yang valid.');
      return;
    }
    if (discount < 0 || discount >= price) {
      _showAlert('Discount harus antara 0 dan kurang dari Price.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await WeaponService.createWeapon(
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
      widget.onCreated?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final sheetBg   = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final fieldBg   = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText   = isDark ? const Color(0xFF88888A) : const Color(0xFF8A8A8E);
    final border    = subText.withValues(alpha: 0.2);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ColoredBox(
          color: sheetBg,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Weapon',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Row 1: Image + Name / Type / Rarity ───────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // image picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
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
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: subText, size: 30),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Image',
                                        style: TextStyle(
                                          color: subText,
                                          fontFamily: 'Alexandria',
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Item's Name", textColor),
                              const SizedBox(height: 6),
                              _field(
                                controller: _titleCtrl,
                                hint: 'e.g. Aquila Favonia',
                                fieldBg: fieldBg,
                                textColor: textColor,
                                subText: subText,
                              ),
                              const SizedBox(height: 10),
                              _label('Category', textColor),
                              const SizedBox(height: 6),
                              _dropdown(
                                value: _type,
                                items: _types,
                                fieldBg: fieldBg,
                                textColor: textColor,
                                subText: subText,
                                onChanged: (v) => setState(() => _type = v!),
                              ),
                              const SizedBox(height: 10),
                              _label('Rarity', textColor),
                              const SizedBox(height: 6),
                              _rarityPicker(subText),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Row 2: Price + Discount ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Price', textColor),
                              const SizedBox(height: 6),
                              _field(
                                controller: _priceCtrl,
                                hint: '0',
                                fieldBg: fieldBg,
                                textColor: textColor,
                                subText: subText,
                                keyboardType: TextInputType.number,
                                prefix: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 6),
                                  child: Image.asset('assets/icon/coin.png', width: 16, height: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Discount', textColor),
                              const SizedBox(height: 6),
                              _field(
                                controller: _discountCtrl,
                                hint: '0',
                                fieldBg: fieldBg,
                                textColor: textColor,
                                subText: subText,
                                keyboardType: TextInputType.number,
                                prefix: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 6),
                                  child: Image.asset('assets/icon/coin.png', width: 16, height: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Row 3: Base ATK + Sub Stat ────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Base ATK', textColor),
                              const SizedBox(height: 6),
                              _field(
                                controller: _baseAtkCtrl,
                                hint: '0',
                                fieldBg: fieldBg,
                                textColor: textColor,
                                subText: subText,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Sub Stat', textColor),
                              const SizedBox(height: 6),
                              _field(
                                controller: _subStatCtrl,
                                hint: 'e.g. Physical DMG',
                                fieldBg: fieldBg,
                                textColor: textColor,
                                subText: subText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Passive Name ──────────────────────────────────────
                    _label('Passive Name', textColor),
                    const SizedBox(height: 6),
                    _field(
                      controller: _passiveNameCtrl,
                      hint: "e.g. Falcon's Defiance",
                      fieldBg: fieldBg,
                      textColor: textColor,
                      subText: subText,
                    ),
                    const SizedBox(height: 16),

                    // ── Description ───────────────────────────────────────
                    _label('Description', textColor),
                    const SizedBox(height: 6),
                    _field(
                      controller: _descCtrl,
                      hint: 'Weapon passive description...',
                      fieldBg: fieldBg,
                      textColor: textColor,
                      subText: subText,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // ── Create Button ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A3A3A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF3A3A3A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create New Card',
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
    );
  }

  Widget _rarityPicker(Color subText) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => setState(() => _rarity = star),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Image.asset(
              'assets/icon/star.png',
              width: 22,
              height: 22,
              color: star <= _rarity ? const Color(0xFFD4AF37) : subText,
            ),
          ),
        );
      }),
    );
  }

  Widget _label(String text, Color color) => Text(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'Alexandria',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required Color fieldBg,
    required Color textColor,
    required Color subText,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: subText.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
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
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Color fieldBg,
    required Color textColor,
    required Color subText,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
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
  }
}
