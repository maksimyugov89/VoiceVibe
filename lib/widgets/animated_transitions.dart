import 'package:flutter/material.dart';

// Плавный переход с fade эффектом
class FadeRoute extends PageRouteBuilder<void> {
  final Widget page;
  
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

// Слайд переход снизу вверх
class SlideUpRoute extends PageRouteBuilder<void> {
  final Widget page;
  
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.elasticOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

// Масштабный переход
class ScaleRoute extends PageRouteBuilder<void> {
  final Widget page;
  
  ScaleRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const curve = Curves.elasticInOut;
            var scaleTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeIn),
            );

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

// Hero-подобный переход для карточек
class CardExpandRoute extends PageRouteBuilder<void> {
  final Widget page;
  final Offset startPosition;
  
  CardExpandRoute({required this.page, required this.startPosition})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            var scaleTween = Tween(begin: 0.3, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut));

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleTween.evaluate(animation),
                  child: child,
                );
              },
              child: child,
            );
          },
        );
}

// Анимированный контейнер для переключения между экранами
class AnimatedScreenSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  
  const AnimatedScreenSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));
        
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Shared Element Transition для Hero анимаций
class SharedElementRoute extends PageRouteBuilder<void> {
  final Widget page;
  final String tag;
  
  SharedElementRoute({required this.page, required this.tag})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1.0),
              ),
              child: child,
            );
          },
        );
}

// Пример использования в навигации
class NavigationHelper {
  static void navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(FadeRoute(page: page));
  }
  
  static void navigateWithSlideUp(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideUpRoute(page: page));
  }
  
  static void navigateWithScale(BuildContext context, Widget page) {
    Navigator.of(context).push(ScaleRoute(page: page));
  }
  
  static void navigateWithCardExpand(
    BuildContext context, 
    Widget page, 
    Offset startPosition,
  ) {
    Navigator.of(context).push(
      CardExpandRoute(page: page, startPosition: startPosition),
    );
  }
}