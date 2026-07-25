import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/diary_providers.dart';
import '../widgets/pin_keypad.dart';

const int _pinLength = 6;

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _firstPin = '';
  String _input = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String d) {
    if (_input.length >= _pinLength) return;
    setState(() {
      _input += d;
      _error = null;
    });
    if (_input.length == _pinLength) _handleComplete();
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _handleComplete() async {
    if (!_confirming) {
      setState(() {
        _firstPin = _input;
        _input = '';
        _confirming = true;
      });
      return;
    }

    if (_input != _firstPin) {
      setState(() {
        _error = 'PIN tidak cocok, coba lagi';
        _input = '';
        _confirming = false;
        _firstPin = '';
      });
      return;
    }

    await ref.read(setupPinUseCaseProvider).call(_input);
    ref.read(diaryLockProvider.notifier).unlock();
    if (mounted) Navigator.of(context).pop();
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
              const SizedBox(height: 24),
              const Icon(Icons.lock_outline, size: 40, color: AppColors.diaryAccentDark),
              const SizedBox(height: 16),
              Text(
                _confirming ? 'Konfirmasi PIN kamu' : 'Buat PIN untuk Diary',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Penting: catatan diary dienkripsi memakai PIN ini. '
                  'Jika PIN lupa dan direset, semua catatan lama akan terhapus '
                  'permanen karena tidak bisa didekripsi lagi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.65)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.priorityHigh)),
              ],
              const Spacer(),
              PinKeypad(
                pinLength: _input.length,
                maxLength: _pinLength,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                shakeKey: _error != null ? UniqueKey() : null,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
