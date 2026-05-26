import 'package:flutter/material.dart';

class ControlsWidget extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onHold;

  const ControlsWidget({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    required this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row: Hold | Rotate | Hard Drop
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _GameButton(
              icon: Icons.swap_horiz,
              label: 'HOLD',
              onTap: onHold,
              color: const Color(0xFF334466),
            ),
            _GameButton(
              icon: Icons.rotate_right,
              label: 'ROTATE',
              onTap: onRotate,
              color: const Color(0xFF553366),
            ),
            _GameButton(
              icon: Icons.vertical_align_bottom,
              label: 'DROP',
              onTap: onHardDrop,
              color: const Color(0xFF334433),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row: Left | Soft Drop | Right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _GameButton(
              icon: Icons.arrow_back_ios,
              label: 'LEFT',
              onTap: onLeft,
              color: const Color(0xFF334466),
            ),
            _GameButton(
              icon: Icons.arrow_downward,
              label: 'DOWN',
              onTap: onSoftDrop,
              color: const Color(0xFF334466),
            ),
            _GameButton(
              icon: Icons.arrow_forward_ios,
              label: 'RIGHT',
              onTap: onRight,
              color: const Color(0xFF334466),
            ),
          ],
        ),
      ],
    );
  }
}

class _GameButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _GameButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  State<_GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<_GameButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 76,
        height: 64,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withValues(alpha:0.9)
              : widget.color.withValues(alpha:0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pressed
                ? Colors.white.withValues(alpha:0.4)
                : Colors.white.withValues(alpha:0.15),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
