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
  final _titleCtrl   = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _baseAtkCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();

  String _type    = 'Sword';
  int    _rarity  = 3;
  File?  _imageFile;
  bool   _isLoading = false;

  static const _types = ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _baseAtkCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final title  = _titleCtrl.text.trim();
    final price  = double.tryParse(_priceCtrl.text.trim());
    final baseAtk = double.tryParse(_baseAtkCtrl.text.trim());

    if (title.isEmpty || price == null || baseAtk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await WeaponService.createWeapon(
        title: title,
        type: _type,
        rarity: _rarity,
        price: price,
        baseAtk: baseAtk,
        description: _descCtrl.text.trim(),
        imageFile: _imageFile,
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

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ColoredBox(
          color: sheetBg,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.asset('assets/icon/Polygon.png', width: 20, height: 20),
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
                    // image + name/category/rarity row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: fieldBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: subText.withValues(alpha: 0.2)),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: subText, size: 28),
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
                                hint: 'Weapon name',
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label('Description', textColor),
                    const SizedBox(height: 6),
                    _field(
                      controller: _descCtrl,
                      hint: 'Weapon passive description...',
                      fieldBg: fieldBg,
                      textColor: textColor,
                      subText: subText,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
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
            child: Icon(
              Icons.star,
              size: 22,
              color: star <= _rarity ? const Color(0xFFD4AF37) : subText,
            ),
          ),
        );
      }),
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: 'Alexandria',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

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
          items: items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
