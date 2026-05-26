import 'dart:math';
import 'package:flutter/material.dart';
import 'tetromino.dart';

const int boardRows = 20;
const int boardCols = 10;

// null = empty, Color = locked cell
typedef Board = List<List<Color?>>;

class GameState {
  Board board;
  Tetromino? current;
  Tetromino? held;
  bool holdUsed;
  List<TetrominoType> bag;
  List<TetrominoType> nextPieces; // preview queue (3 pieces)
  int score;
  int level;
  int lines;
  bool isOver;
  bool isPaused;

  GameState._({
    required this.board,
    required this.current,
    required this.held,
    required this.holdUsed,
    required this.bag,
    required this.nextPieces,
    required this.score,
    required this.level,
    required this.lines,
    required this.isOver,
    required this.isPaused,
  });

  factory GameState.initial() {
    final bag = _newBag();
    final nextPieces = <TetrominoType>[];
    // fill preview
    while (nextPieces.length < 3) {
      nextPieces.add(bag.removeLast());
    }
    final current = Tetromino.spawn(bag.removeLast());
    if (bag.isEmpty) bag.addAll(_newBag());

    return GameState._(
      board: List.generate(boardRows, (_) => List.filled(boardCols, null)),
      current: current,
      held: null,
      holdUsed: false,
      bag: bag,
      nextPieces: nextPieces,
      score: 0,
      level: 1,
      lines: 0,
      isOver: false,
      isPaused: false,
    );
  }

  static List<TetrominoType> _newBag() {
    final bag = TetrominoType.values.toList()..shuffle(Random());
    return bag;
  }

  // ── Bag / next piece ──────────────────────────────────────────────────────

  TetrominoType _pullNext() {
    final next = nextPieces.removeAt(0);
    if (bag.isEmpty) bag.addAll(_newBag());
    nextPieces.add(bag.removeLast());
    return next;
  }

  // ── Collision ─────────────────────────────────────────────────────────────

  bool _collides(Tetromino piece) {
    for (final cell in piece.absoluteCells()) {
      final r = cell[0], c = cell[1];
      if (r >= boardRows || c < 0 || c >= boardCols) return true;
      if (r >= 0 && board[r][c] != null) return true;
    }
    return false;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  GameState moveLeft() {
    if (current == null || isOver || isPaused) return this;
    final moved = current!.copyWith(x: current!.x - 1);
    if (!_collides(moved)) {
      return _copy(current: moved);
    }
    return this;
  }

  GameState moveRight() {
    if (current == null || isOver || isPaused) return this;
    final moved = current!.copyWith(x: current!.x + 1);
    if (!_collides(moved)) {
      return _copy(current: moved);
    }
    return this;
  }

  GameState rotate() {
    if (current == null || isOver || isPaused) return this;
    final nextRot = (current!.rotation + 1) % 4;
    final rotated = current!.copyWith(rotation: nextRot);
    // Try base position, then wall kicks
    for (final kick in _wallKicks(current!.rotation, nextRot)) {
      final kicked = rotated.copyWith(x: rotated.x + kick[1], y: rotated.y + kick[0]);
      if (!_collides(kicked)) return _copy(current: kicked);
    }
    return this;
  }

  GameState rotateCounter() {
    if (current == null || isOver || isPaused) return this;
    final nextRot = (current!.rotation + 3) % 4;
    final rotated = current!.copyWith(rotation: nextRot);
    for (final kick in _wallKicks(current!.rotation, nextRot)) {
      final kicked = rotated.copyWith(x: rotated.x + kick[1], y: rotated.y + kick[0]);
      if (!_collides(kicked)) return _copy(current: kicked);
    }
    return this;
  }

  GameState softDrop() {
    if (current == null || isOver || isPaused) return this;
    final dropped = current!.copyWith(y: current!.y + 1);
    if (!_collides(dropped)) {
      return _copy(current: dropped, score: score + 1);
    }
    return _lock();
  }

  GameState hardDrop() {
    if (current == null || isOver || isPaused) return this;
    var dropped = current!;
    int count = 0;
    while (true) {
      final next = dropped.copyWith(y: dropped.y + 1);
      if (_collides(next)) break;
      dropped = next;
      count++;
    }
    return _copy(current: dropped, score: score + count * 2)._lock();
  }

  GameState tick() {
    if (current == null || isOver || isPaused) return this;
    return softDrop();
  }

  GameState hold() {
    if (current == null || isOver || isPaused || holdUsed) return this;
    Tetromino next;
    if (held == null) {
      next = Tetromino.spawn(_pullNext());
    } else {
      next = Tetromino.spawn(held!.type);
    }
    if (_collides(next)) return this;
    return _copy(
      held: Tetromino(type: current!.type),
      current: next,
      holdUsed: true,
    );
  }

  GameState togglePause() => _copy(isPaused: !isPaused);

  // ── Ghost piece ───────────────────────────────────────────────────────────

  Tetromino? get ghost {
    if (current == null) return null;
    var g = current!;
    while (true) {
      final next = g.copyWith(y: g.y + 1);
      if (_collides(next)) break;
      g = next;
    }
    return g.y != current!.y ? g : null;
  }

  // ── Lock ──────────────────────────────────────────────────────────────────

  GameState _lock() {
    if (current == null) return this;
    final newBoard = board.map((r) => List<Color?>.from(r)).toList();

    for (final cell in current!.absoluteCells()) {
      final r = cell[0], c = cell[1];
      if (r < 0) {
        // Piece locked above board = game over
        return _copy(isOver: true, current: null);
      }
      newBoard[r][c] = current!.color;
    }

    // Clear full lines
    final cleared = newBoard.where((row) => row.every((c) => c != null)).length;
    final newLines = newBoard.where((row) => row.every((c) => c != null) == false).toList();
    while (newLines.length < boardRows) {
      newLines.insert(0, List.filled(boardCols, null));
    }

    final newScore = score + _scoreForLines(cleared);
    final totalLines = lines + cleared;
    final newLevel = (totalLines ~/ 10) + 1;

    final nextType = _pullNext();
    final next = Tetromino.spawn(nextType);

    final nextState = _copy(
      board: newLines,
      current: next,
      holdUsed: false,
      score: newScore,
      lines: totalLines,
      level: newLevel,
    );

    if (nextState._collides(next)) {
      return nextState._copy(isOver: true);
    }
    return nextState;
  }

  int _scoreForLines(int cleared) {
    const base = [0, 100, 300, 500, 800];
    return (cleared < base.length ? base[cleared] : 800) * level;
  }

  // ── Wall kicks (basic SRS subset) ─────────────────────────────────────────

  List<List<int>> _wallKicks(int from, int to) {
    // [row offset, col offset]
    return [
      [0, 0],
      [0, -1],
      [0, 1],
      [-1, 0],
      [-1, -1],
      [-1, 1],
    ];
  }

  // ── Copy helper ───────────────────────────────────────────────────────────

  GameState _copy({
    Board? board,
    Tetromino? current,
    Object? held = _sentinel,
    bool? holdUsed,
    List<TetrominoType>? bag,
    List<TetrominoType>? nextPieces,
    int? score,
    int? level,
    int? lines,
    bool? isOver,
    bool? isPaused,
  }) {
    return GameState._(
      board: board ?? this.board,
      current: current ?? this.current,
      held: held == _sentinel ? this.held : held as Tetromino?,
      holdUsed: holdUsed ?? this.holdUsed,
      bag: bag ?? List<TetrominoType>.from(this.bag),
      nextPieces: nextPieces ?? List<TetrominoType>.from(this.nextPieces),
      score: score ?? this.score,
      level: level ?? this.level,
      lines: lines ?? this.lines,
      isOver: isOver ?? this.isOver,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

const _sentinel = Object();
