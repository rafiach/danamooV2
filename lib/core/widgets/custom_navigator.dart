import 'package:flutter/material.dart';

enum NavAnimation { slide, fade, scale, slideUp, none }

class CustomNavigator {
  // ================= PUSH =================
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    NavAnimation animation = NavAnimation.slide,
  }) {
    return Navigator.of(context).push<T>(_createRoute(page, animation));
  }

  // ================= REPLACE =================
  static Future<T?> replace<T>(
    BuildContext context,
    Widget page, {
    NavAnimation animation = NavAnimation.slide,
  }) {
    return Navigator.of(
      context,
    ).pushReplacement<T, dynamic>(_createRoute(page, animation));
  }

  // ================= REMOVE UNTIL =================
  static Future<T?> removeUntil<T>(
    BuildContext context,
    Widget page, {
    NavAnimation animation = NavAnimation.slide,
  }) {
    return Navigator.of(
      context,
    ).pushAndRemoveUntil<T>(_createRoute(page, animation), (route) => false);
  }

  // ================= PUSH WITH KEEP SOME STACK =================
  /// Menghapus route sampai kondisi terpenuhi
  /// Contoh: CustomNavigator.removeUntilNamed(context, HomePage(), (r) => r.isFirst)
  static Future<T?> removeUntilPredicate<T>(
    BuildContext context,
    Widget page,
    RoutePredicate predicate, {
    NavAnimation animation = NavAnimation.slide,
  }) {
    return Navigator.of(
      context,
    ).pushAndRemoveUntil<T>(_createRoute(page, animation), predicate);
  }

  // ================= POP =================
  static void pop<T>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<T>(result);
    }
  }

  // ================= POP UNTIL =================
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.of(context).popUntil(predicate);
  }

  // ================= POP TO FIRST =================
  static void popToFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ================= CAN POP =================
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  // ================= ROUTE BUILDER =================
  static Route<T> _createRoute<T>(Widget page, NavAnimation animation) {
    switch (animation) {
      case NavAnimation.slide:
        return _slideRoute(page);
      case NavAnimation.fade:
        return _fadeRoute(page);
      case NavAnimation.scale:
        return _scaleRoute(page);
      case NavAnimation.slideUp:
        return _slideUpRoute(page);
      case NavAnimation.none:
        return _noAnimationRoute(page);
    }
  }

  // ================= SLIDE (dari kanan) =================
  static PageRouteBuilder<T> _slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));

        // Slide current page out to left when going back
        final secondaryTween = Tween(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: SlideTransition(
            position: secondaryAnimation.drive(secondaryTween),
            child: child,
          ),
        );
      },
    );
  }

  // ================= FADE =================
  static PageRouteBuilder<T> _fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  // ================= SCALE (zoom in) =================
  static PageRouteBuilder<T> _scaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // ================= SLIDE UP (dari bawah) =================
  static PageRouteBuilder<T> _slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  // ================= NO ANIMATION =================
  static PageRouteBuilder<T> _noAnimationRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
