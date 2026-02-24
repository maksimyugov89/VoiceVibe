import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ModernNoteCard extends StatefulWidget {
  final String title;
  final String text;
  final DateTime date;
  final Duration? duration;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final int index;

  const ModernNoteCard({
    super.key,
    required this.title,
    required this.text,
    required this.date,
    this.duration,
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
    required this.index,
  });

  @override
  State<ModernNoteCard> createState() => _ModernNoteCardState();
}

class _ModernNoteCardState extends State<ModernNoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;
  bool _showActions = false;

  late final List<Color> gradientColors;
  late final String formattedDateTime; 
  late final String? formattedDuration;
  late final Color shadowColor;

  static const List<List<Color>> cardGradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFF30cfd0), Color(0xFF330867)],
  ];

  @override
  void initState() {
    super.initState();
    gradientColors = cardGradients[widget.index % cardGradients.length];
    shadowColor = gradientColors.first.withOpacity(0.3);
    
    formattedDateTime = DateFormat('dd.MM.yyyy HH:mm').format(widget.date);
    
    if (widget.duration != null) {
      formattedDuration = _formatDuration(widget.duration!);
    } else {
      formattedDuration = null;
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _showActions = !_showActions);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        formattedDateTime, 
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            Text(
                              widget.text.isEmpty 
                                ? 'Нет текста' 
                                : widget.text,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _showActions
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _ActionButton(
                                          icon: widget.isPlaying 
                                              ? Icons.stop_rounded 
                                              : Icons.play_arrow_rounded,
                                          label: widget.isPlaying 
                                              ? 'Стоп' 
                                              : 'Играть',
                                          onTap: widget.isPlaying 
                                              ? widget.onStop 
                                              : widget.onPlay,
                                        ),
                                        _ActionButton(
                                          icon: Icons.edit_rounded,
                                          label: 'Изменить',
                                          onTap: widget.onEdit,
                                        ),
                                        _ActionButton(
                                          icon: Icons.share_rounded,
                                          label: 'Экспорт',
                                          onTap: widget.onExport,
                                        ),
                                        _ActionButton(
                                          icon: Icons.delete_rounded,
                                          label: 'Удалить',
                                          onTap: widget.onDelete,
                                          isDestructive: true,
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    // ИСПРАВЛЕНИЕ ЗДЕСЬ: Добавлено ключевое слово 'return'
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDestructive 
                ? Colors.redAccent 
                : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDestructive 
                  ? Colors.redAccent 
                  : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}