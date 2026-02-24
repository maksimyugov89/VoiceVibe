import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера анимации
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Анимация масштабирования (пульсация)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Переход на главный экран через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.diagonal3Values(_scaleAnimation.value, _scaleAnimation.value, 1.0),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash/splash_light.png', // Путь к логотипу
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'VoiceVibe',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3), // Синий цвет VoiceVibe
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Записывай. Расшифровывай. Планируй.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Color(0xFF4CAF50), // Зелёный цвет
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}