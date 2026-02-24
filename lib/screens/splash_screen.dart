import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Больше не нужно управлять таймером или навигацией отсюда.
    // Оставляем этот метод пустым.
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final splashImage = isDarkMode
        ? 'assets/splash/splash_dark.png'
        : 'assets/splash/splash_light.png';
    final animationColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            splashImage,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  animationColor,
                  BlendMode.srcIn,
                ),
                child: Lottie.asset(
                  'assets/lottie/splash_animation.json',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}