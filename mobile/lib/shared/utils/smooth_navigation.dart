import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SmoothPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;
           const curve = Curves.easeInOut;

           var tween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));

           return SlideTransition(
             position: animation.drive(tween),
             child: FadeTransition(opacity: animation, child: child),
           );
         },
       );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
               CurvedAnimation(parent: animation, curve: Curves.easeInOut),
             ),
             child: child,
           );
         },
       );
}

// Helper methods for easy navigation
class SmoothNavigation {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, SmoothPageRoute<T>(page: page));
  }

  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, TO>(
      context,
      SmoothPageRoute<T>(page: page),
    );
  }

  static Future<T?> fadeIn<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, FadePageRoute<T>(page: page));
  }
}
