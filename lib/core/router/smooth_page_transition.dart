import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transisi halaman standar di seluruh app: fade + slide tipis dari bawah,
/// dengan curve easeOutCubic supaya terasa halus (bukan langsung snap
/// seperti transisi default Material yang agak kaku untuk app sederhana).
CustomTransitionPage<T> buildSmoothPage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
