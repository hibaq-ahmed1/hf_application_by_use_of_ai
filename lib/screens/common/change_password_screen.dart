import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<AuthProvider>().changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
          confirmPassword: _confirm.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Update your account password. You’ll use the new password the next time you sign in.',
            style: TextStyle(color: AppColors.inkMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _current,
            obscureText: _obscure,
            decoration: const InputDecoration(
              labelText: 'Current password',
              prefixIcon: Icon(LucideIcons.lock, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _next,
            obscureText: _obscure,
            decoration: const InputDecoration(
              labelText: 'New password',
              prefixIcon: Icon(LucideIcons.keyRound, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              prefixIcon: const Icon(LucideIcons.keyRound, size: 18),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 18),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save password'),
          ),
        ],
      ),
    );
  }
}
