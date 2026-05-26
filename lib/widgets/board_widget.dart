import 'package:flutter/material.dart';
import '../models/game_state.dart';

class BoardWidget extends StatelessWidget {
  final GameState state;
  final double cellSize;

  const BoardWidget({super.key, required this.state, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    // Build a merged grid: board + ghost + current piece
    final grid = state.board
        .map((row) => List<Color?>.from(row))
        .toList();

    // Paint ghost
    final ghost = state.ghost;
    if (ghost != null) {
      for (final cell in ghost.absoluteCells()) {
        final r = cell[0], c = cell[1];
        if (r >= 0 && r < boardRows && c >= 0 && c < boardCols) {
          grid[r][c] ??= ghost.color.withValues(alpha:0.25);
        }
      }
    }

    // Paint current piece
    if (state.current != null) {
      for (final cell in state.current!.absoluteCells()) {
        final r = cell[0], c = cell[1];
        if (r >= 0 && r < boardRows && c >= 0 && c < boardCols) {
          grid[r][c] = state.current!.color;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A),
        border: Border.all(color: const Color(0xFF334466), width: 2),
      ),
      width: cellSize * boardCols,
      height: cellSize * boardRows,
      child: CustomPaint(
        painter: _BoardPainter(grid: grid, cellSize: cellSize),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<List<Color?>> grid;
  final double cellSize;

  _BoardPainter({required this.grid, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int r = 0; r < boardRows; r++) {
      for (int c = 0; c < boardCols; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize, r * cellSize, cellSize, cellSize,
        );
        final color = grid[r][c];
        if (color != null) {
          // Filled cell
          final fillPaint = Paint()..color = color;
          canvas.drawRect(rect, fillPaint);

          // Highlight top-left edge
          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha:0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          final innerRect = Rect.fromLTWH(
            c * cellSize + 1, r * cellSize + 1,
            cellSize - 2, cellSize - 2,
          );
          canvas.drawRect(innerRect, highlightPaint);
        }
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}
