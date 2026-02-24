import 'package:flutter/material.dart';
import 'dart:math' as math;

// Класс для эффективного рисования волн
class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 3; i++) {
      // Создаем эффект расходящихся волн, сдвигая фазу для каждой
      final waveProgress = (progress + i * 0.33) % 1.0;
      final radius = 40 + (50 * waveProgress);
      
      final paint = Paint()
        ..color = color.withOpacity((1 - waveProgress) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - (waveProgress * 2.5); // Делаем линии чуть толще вначале
        
      if (paint.strokeWidth > 0) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class AnimatedRecordButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onStop;
  final bool isRecording;
  final bool isPaused;
  final bool isProcessing;

  const AnimatedRecordButton({
    super.key,
    required this.onPressed,
    required this.onStop,
    this.isRecording = false,
    this.isPaused = false,
    this.isProcessing = false,
  });

  @override
  State<AnimatedRecordButton> createState() => _AnimatedRecordButtonState();
}

class _AnimatedRecordButtonState extends State<AnimatedRecordButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _updateAnimations();
  }

  void _updateAnimations() {
    if (widget.isRecording && !widget.isPaused) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
      _rotationController.stop();
    } else if (widget.isPaused) {
      _pulseController.stop();
      _waveController.stop();
      _rotationController.repeat();
    } else {
      _pulseController.reset();
      _waveController.stop();
      _rotationController.stop();
    }
  }

  @override
  void didUpdateWidget(AnimatedRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording ||
        oldWidget.isPaused != widget.isPaused) {
      _updateAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.isProcessing ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: widget.isProcessing ? null : (widget.isRecording ? widget.onStop : widget.onPressed),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Оптимизированная анимация волн
            if (widget.isRecording && !widget.isPaused)
              AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(180, 180),
                    painter: _WavePainter(
                      progress: _waveAnimation.value,
                      color: const Color(0xFFFF6B9D),
                    ),
                  );
                },
              ),

            // Основная кнопка
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: (widget.isRecording && !widget.isPaused) ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: widget.isPaused ? _rotationController.value * 2 * math.pi : 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: widget.isRecording
                              ? [const Color(0xFFFF6B9D), const Color(0xFFFD79A8)]
                              : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isRecording
                                    ? const Color(0xFFFF6B9D)
                                    : const Color(0xFF6C5CE7))
                                .withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Иконка (становится невидимой во время обработки)
                            Opacity(
                              opacity: widget.isProcessing ? 0.0 : 1.0,
                              child: Icon(
                                widget.isRecording
                                    ? (widget.isPaused ? Icons.pause_rounded : Icons.stop_rounded)
                                    : Icons.mic_rounded,
                                key: ValueKey('${widget.isRecording}-${widget.isPaused}'),
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            // Индикатор загрузки (появляется во время обработки)
                            if (widget.isProcessing)
                              const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Визуализатор звуковых волн (без изменений)
class SoundWaveVisualizer extends StatefulWidget {
  final bool isActive;
  final double height;
  final double width;

  const SoundWaveVisualizer({
    super.key,
    required this.isActive,
    this.height = 100,
    this.width = 300,
  });

  @override
  State<SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heights = List.generate(30, (index) => 0.3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.isActive) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _controller.addListener(() {
      if (mounted && widget.isActive) {
        setState(() {
          for (int i = 0; i < _heights.length; i++) {
            _heights[i] = 0.3 + (math.Random().nextDouble() * 0.7);
          }
        });
      }
    });
    if (mounted && widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SoundWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _controller.stop();
        if (mounted) {
          setState(() {
            for (int i = 0; i < _heights.length; i++) {
              _heights[i] = 0.3;
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_heights.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: (widget.width / _heights.length) * 0.7,
            height: widget.height * _heights[index],
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6C5CE7),
                  Color(0xFFA29BFE),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}