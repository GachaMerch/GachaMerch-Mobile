import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileEditDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onSaved;

  const ProfileEditDialog({super.key, required this.user, required this.onSaved});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _nameCtrl;
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  bool _showPass = false;
  bool _showConfirmPass = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.user['username']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_passCtrl.text.isNotEmpty && _passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (_passCtrl.text.isNotEmpty && _passCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final updated = await AuthService.updateProfile(
        username: _nameCtrl.text.trim(),
        password: _passCtrl.text.isNotEmpty ? _passCtrl.text : null,
      );
      widget.onSaved(updated);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? const Color(0xFF88888A) : const Color(0xFF8A8A8E);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Edit',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Alexandria',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: subText, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label("Player's Name", textColor),
            const SizedBox(height: 6),
            _field(
              controller: _nameCtrl,
              hint: 'Your Name',
              fieldBg: fieldBg,
              textColor: textColor,
              subText: subText,
              suffix: Icon(Icons.edit_outlined, color: subText, size: 18),
            ),
            const SizedBox(height: 12),
            _label('Change Password', textColor),
            const SizedBox(height: 6),
            _field(
              controller: _passCtrl,
              hint: 'min. 8 characters',
              fieldBg: fieldBg,
              textColor: textColor,
              subText: subText,
              obscure: !_showPass,
              suffix: GestureDetector(
                onTap: () => setState(() => _showPass = !_showPass),
                child: Icon(
                  _showPass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: subText,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _label('Confirm Password', textColor),
            const SizedBox(height: 6),
            _field(
              controller: _confirmPassCtrl,
              hint: 'min. 8 characters',
              fieldBg: fieldBg,
              textColor: textColor,
              subText: subText,
              obscure: !_showConfirmPass,
              suffix: GestureDetector(
                onTap: () =>
                    setState(() => _showConfirmPass = !_showConfirmPass),
                child: Icon(
                  _showConfirmPass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: subText,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
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
                        'Save Changes',
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
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: 'Alexandria',
        fontSize: 13,
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
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: subText.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Alexandria',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: subText, fontSize: 14),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
