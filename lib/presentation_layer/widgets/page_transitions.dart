import 'package:flutter/material.dart';

class PageTransitions {
  // 1. انتقال التلاشي (مناسب للفئات والقوائم)
  static Route fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  // 2. انتقال الإزاحة من اليمين (مناسب لبروفايل المورد)
  static Route slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // يبدأ من اليمين
        const end = Offset.zero;
        const curve = Curves.easeOutQuart; // منحنى احترافي سلس

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Route slideFromLeft(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // ابدأ من -1.0 (أقصى اليسار) إلى 0.0 (المركز)
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;

        // منحنى FastOutSlowIn يعطي شعوراً بالسرعة والاحترافية
        const curve = Curves.fastOutSlowIn;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      // سرعة الانتقال (300ms تعتبر مثالية للتطبيقات السريعة)
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
