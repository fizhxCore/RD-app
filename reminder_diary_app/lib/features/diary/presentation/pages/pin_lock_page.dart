import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/diary_providers.dart';
import '../widgets/pin_keypad.dart';

const int _pinLength = 6;

class PinLockPage extends ConsumerStatefulWidget {
  const PinLockPage({super.key});

  @override
  ConsumerState<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends ConsumerState<PinLockPage> {
  String _input = '';
  bool _error = false;

  void _onDigit(String d) {
    if (_input.length >= _pinLength) return;
    setState(() {
      _input += d;
      _error = false;
    });
    if (_input.length == _pinLength) _verify();
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _verify() async {
    final correct = await ref.read(verifyPinUseCaseProvider).call(_input);
    if (correct) {
      ref.read(diaryLockProvider.notifier).unlock();
    } else {
      setState(() {
        _error = true;
        _input = '';
      });
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lupa PIN?'),
        content: const Text(
          'Reset PIN akan MENGHAPUS PERMANEN semua catatan diary yang ada, '
          'karena tidak bisa didekripsi tanpa PIN lama. Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus & Reset', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(wipeForPinResetUseCaseProvider).call();
    if (!mounted) return;
    context.go('/diary/pin-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.diaryBgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock, size: 40, color: AppColors.diaryAccentDark),
              const SizedBox(height: 16),
              const Text(
                'Masukkan PIN Diary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              if (_error) ...[
                const SizedBox(height: 10),
                const Text('PIN salah, coba lagi', style: TextStyle(color: AppColors.priorityHigh)),
              ],
              const Spacer(),
              PinKeypad(
                pinLength: _input.length,
                maxLength: _pinLength,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                shakeKey: _error ? UniqueKey() : null,
              ),
              const Spacer(),
              TextButton(
                onPressed: _confirmReset,
                child: Text(
                  'Lupa PIN?',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
