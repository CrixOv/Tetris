import 'package:flutter/material.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Tetromino {
  final TetrominoType type;
  int rotation;
  int x; // board col of pivot
  int y; // board row of pivot

  Tetromino({required this.type, this.rotation = 0, this.x = 3, this.y = 0});

  static const Map<TetrominoType, Color> colors = {
    TetrominoType.I: Color(0xFF00CFCF),
    TetrominoType.O: Color(0xFFCFCF00),
    TetrominoType.T: Color(0xFF9F00CF),
    TetrominoType.S: Color(0xFF00CF00),
    TetrominoType.Z: Color(0xFFCF0000),
    TetrominoType.J: Color(0xFF0000CF),
    TetrominoType.L: Color(0xFFCF7F00),
  };

  // Each piece has 4 rotations; each rotation is a list of [row, col] offsets
  static const Map<TetrominoType, List<List<List<int>>>> shapes = {
    TetrominoType.I: [
      [[-1, 0], [0, 0], [1, 0], [2, 0]],
      [[0, -1], [0, 0], [0, 1], [0, 2]],
      [[-1, 0], [0, 0], [1, 0], [2, 0]],
      [[0, -1], [0, 0], [0, 1], [0, 2]],
    ],
    TetrominoType.O: [
      [[0, 0], [0, 1], [1, 0], [1, 1]],
      [[0, 0], [0, 1], [1, 0], [1, 1]],
      [[0, 0], [0, 1], [1, 0], [1, 1]],
      [[0, 0], [0, 1], [1, 0], [1, 1]],
    ],
    TetrominoType.T: [
      [[0, -1], [0, 0], [0, 1], [1, 0]],
      [[-1, 0], [0, 0], [1, 0], [0, 1]],
      [[-1, 0], [0, -1], [0, 0], [0, 1]],
      [[-1, 0], [0, -1], [0, 0], [1, 0]],
    ],
    TetrominoType.S: [
      [[0, 0], [0, 1], [1, -1], [1, 0]],
      [[-1, 0], [0, 0], [0, 1], [1, 1]],
      [[0, 0], [0, 1], [1, -1], [1, 0]],
      [[-1, 0], [0, 0], [0, 1], [1, 1]],
    ],
    TetrominoType.Z: [
      [[0, -1], [0, 0], [1, 0], [1, 1]],
      [[0, 0], [0, 1], [-1, 0], [-1, -1]],
      [[0, -1], [0, 0], [1, 0], [1, 1]],
      [[0, 0], [0, 1], [-1, 0], [-1, -1]],
    ],
    TetrominoType.J: [
      [[-1, -1], [0, -1], [0, 0], [0, 1]],
      [[-1, 0], [0, 0], [1, 0], [1, 1]],
      [[0, -1], [0, 0], [0, 1], [1, 1]],
      [[-1, -1], [-1, 0], [0, 0], [1, 0]],
    ],
    TetrominoType.L: [
      [[-1, 1], [0, -1], [0, 0], [0, 1]],
      [[-1, 0], [0, 0], [1, 0], [-1, 1]],
      [[0, -1], [0, 0], [0, 1], [1, -1]],
      [[1, -1], [-1, 0], [0, 0], [1, 0]],
    ],
  };

  List<List<int>> get cells => shapes[type]![rotation];

  Color get color => colors[type]!;

  // Absolute board positions of this piece's cells
  List<List<int>> absoluteCells() {
    return cells.map((c) => [y + c[0], x + c[1]]).toList();
  }

  Tetromino copyWith({int? rotation, int? x, int? y}) {
    return Tetromino(
      type: type,
      rotation: rotation ?? this.rotation,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  static Tetromino spawn(TetrominoType type) {
    return Tetromino(type: type, rotation: 0, x: 4, y: 0);
  }
}
