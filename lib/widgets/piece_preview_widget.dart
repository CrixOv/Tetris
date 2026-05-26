import 'package:flutter/material.dart';
import '../models/tetromino.dart';

class PiecePreviewWidget extends StatelessWidget {
  final TetrominoType type;
  final double cellSize;
  final String? label;

  const PiecePreviewWidget({
    super.key,
    required this.type,
    this.cellSize = 14,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final piece = Tetromino(type: type);
    final cells = piece.cells;
    final color = piece.color;

    // Find bounding box
    int minR = 99, maxR = -99, minC = 99, maxC = -99;
    for (final c in cells) {
      minR = min(minR, c[0]);
      maxR = max(maxR, c[0]);
      minC = min(minC, c[1]);
      maxC = max(maxC, c[1]);
    }
    final rows = maxR - minR + 1;
    final cols = maxC - minC + 1;

    return Column(
      children: [
        if (label != null)
          Text(
            label!,
            style: const TextStyle(
              color: Color(0xFF8899BB),
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        if (label != null) const SizedBox(height: 4),
        SizedBox(
          width: 4 * cellSize,
          height: 4 * cellSize,
          child: Center(
            child: CustomPaint(
              size: Size(cols * cellSize, rows * cellSize),
              painter: _PiecePainter(
                cells: cells,
                color: color,
                cellSize: cellSize,
                minR: minR,
                minC: minC,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

int min(int a, int b) => a < b ? a : b;
int max(int a, int b) => a > b ? a : b;

class _PiecePainter extends CustomPainter {
  final List<List<int>> cells;
  final Color color;
  final double cellSize;
  final int minR, minC;

  _PiecePainter({
    required this.cells,
    required this.color,
    required this.cellSize,
    required this.minR,
    required this.minC,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = color;
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final cell in cells) {
      final r = cell[0] - minR;
      final c = cell[1] - minC;
      final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(
        Rect.fromLTWH(c * cellSize + 1, r * cellSize + 1, cellSize - 2, cellSize - 2),
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.color != color || old.cells != cells;
}
