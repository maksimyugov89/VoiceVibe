import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class FloatingBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const FloatingBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<FloatingBottomNavigation> createState() => _FloatingBottomNavigationState();
}

class _FloatingBottomNavigationState extends State<FloatingBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _iconAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _iconAnimations = List.generate(
      3,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.4 + index * 0.1,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(20),
      height: 75,
      // ИЗМЕНЕНИЕ 1: Заменяем ресурсоёмкий BackdropFilter на обычный Container.
      // Это уберёт эффект размытия, но значительно повысит производительность.
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1830).withOpacity(0.85) // Цвет тёмной поверхности с прозрачностью
            : Colors.white.withOpacity(0.9), // Белый с прозрачностью
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.mic_rounded,
            label: 'Заметки',
            index: 0,
            isDark: isDark,
          ),
          _buildNavItem(
            icon: Icons.calendar_today_rounded,
            label: 'Календарь',
            index: 1,
            isDark: isDark,
          ),
          _buildNavItem(
            icon: Icons.settings_rounded,
            label: 'Настройки',
            index: 2,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = widget.selectedIndex == index;
    
    return ScaleTransition(
      scale: _iconAnimations[index],
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onDestinationSelected(index);
          
          // ИЗМЕНЕНИЕ 2: Убираем лишнюю анимацию reverse/forward,
          // которая и вызывала основные подвисания при переключении экранов.
          // Анимации самой иконки более чем достаточно для обратной связи.
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF6C5CE7)),
                size: 24,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Альтернативный вариант - Floating Action Button с расширяющимся меню
class ExpandableFAB extends StatefulWidget {
  final VoidCallback onRecord;
  final VoidCallback onPhoto;
  final VoidCallback onNote;

  const ExpandableFAB({
    super.key,
    required this.onRecord,
    required this.onPhoto,
    required this.onNote,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _expandAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Затемнение фона при раскрытии
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return _expandAnimation.value > 0
                ? GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      color: Colors.black.withOpacity(_expandAnimation.value * 0.5),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        
        // Дополнительные кнопки
        ..._buildExpandableButtons(),
        
        // Основная кнопка
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: const Color(0xFF6C5CE7),
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14,
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandableButtons() {
    final buttons = [
      _ExpandableButton(
        icon: Icons.mic_rounded,
        label: 'Запись',
        color: const Color(0xFFFF6B9D),
        onTap: () {
          widget.onRecord();
          _toggle();
        },
        position: 1,
      ),
      _ExpandableButton(
        icon: Icons.camera_alt_rounded,
        label: 'Фото',
        color: const Color(0xFF00B8D4),
        onTap: () {
          widget.onPhoto();
          _toggle();
        },
        position: 2,
      ),
      _ExpandableButton(
        icon: Icons.note_add_rounded,
        label: 'Текст',
        color: const Color(0xFF26DE81),
        onTap: () {
          widget.onNote();
          _toggle();
        },
        position: 3,
      ),
    ];

    return buttons.map((button) {
      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              -_expandAnimation.value * (80.0 * button.position),
            ),
            child: Opacity(
              opacity: _expandAnimation.value,
              child: button,
            ),
          );
        },
      );
    }).toList();
  }
}

class _ExpandableButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int position;

  const _ExpandableButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            onPressed: onTap,
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}