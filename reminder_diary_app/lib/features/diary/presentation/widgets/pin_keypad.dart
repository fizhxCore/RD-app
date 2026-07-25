import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

/// Numpad custom modern untuk input PIN, dengan indikator titik dan
/// animasi shake ketika [shakeError] di-trigger (PIN salah).
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.pinLength,
    required this.maxLength,
    required this.onDigit,
    required this.onBackspace,
    this.shakeKey,
  });

  final int pinLength;
  final int maxLength;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Key? shakeKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          key: shakeKey,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLength, (i) {
            final filled = i < pinLength;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.diaryAccent : Colors.transparent,
                border: Border.all(color: AppColors.diaryAccent, width: 1.5),
              ),
            );
          }),
        ).animate(key: shakeKey).shakeX(amount: 6),
        const SizedBox(height: 36),
        ..._buildRows(context),
      ],
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    const layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return layout.map((row) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 64, height: 64);
            return _KeyButton(
              label: key,
              onTap: () {
                if (key == '⌫') {
                  onBackspace();
                } else {
                  onDigit(key);
                }
              },
            );
          }).toList(),
        ),
      );
    }).toList();
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
