import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../widgets/board_widget.dart';
import '../widgets/controls_widget.dart';
import '../widgets/piece_preview_widget.dart';

class GameScreen extends StatefulWidget {
  final int highScore;
  final void Function(int score) onGameOver;

  const GameScreen({
    super.key,
    required this.highScore,
    required this.onGameOver,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameState _state;
  Timer? _timer;
  int _highScore = 0;

  // Swipe detection
  Offset? _swipeStart;
  static const double _swipeThreshold = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _highScore = widget.highScore;
    _state = GameState.initial();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_state.isPaused) {
      _doAction(() => _state.togglePause());
    }
  }

  int _tickMs() {
    // Speed formula: starts at 800ms, -60ms per level, floor 80ms
    return (800 - (_state.level - 1) * 60).clamp(80, 800);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _tickMs()), (_) {
      _doAction(() => _state.tick());
    });
  }

  void _doAction(GameState Function() action) {
    if (!mounted) return;
    final prev = _state;
    setState(() => _state = action());
    // If level changed, restart timer with new speed
    if (_state.level != prev.level) _startTimer();
    // If game over
    if (_state.isOver && !prev.isOver) {
      _timer?.cancel();
      _maybeUpdateHighScore();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) widget.onGameOver(_state.score);
      });
    }
  }

  void _maybeUpdateHighScore() {
    if (_state.score > _highScore) {
      setState(() => _highScore = _state.score);
    }
  }

  void _haptic() => HapticFeedback.lightImpact();

  void _onPanStart(DragStartDetails d) => _swipeStart = d.localPosition;

  void _onPanEnd(DragEndDetails d) {
    if (_swipeStart == null) return;
    // Use velocity for quick flicks
    final vel = d.velocity.pixelsPerSecond;
    if (vel.distance > 300) {
      final dx = vel.dx.abs(), dy = vel.dy.abs();
      if (dy > dx) {
        if (vel.dy > 0) { _haptic(); _doAction(() => _state.hardDrop()); }
      } else {
        if (vel.dx < 0) { _haptic(); _doAction(() => _state.moveLeft()); }
        else { _haptic(); _doAction(() => _state.moveRight()); }
      }
    }
    _swipeStart = null;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_swipeStart == null) return;
    final delta = d.localPosition - _swipeStart!;
    if (delta.dx.abs() > _swipeThreshold && delta.dx.abs() > delta.dy.abs()) {
      if (delta.dx < 0) { _haptic(); _doAction(() => _state.moveLeft()); }
      else { _haptic(); _doAction(() => _state.moveRight()); }
      _swipeStart = d.localPosition;
    } else if (delta.dy > _swipeThreshold * 1.5 && delta.dy > delta.dx.abs()) {
      _haptic();
      _doAction(() => _state.softDrop());
      _swipeStart = d.localPosition;
    }
  }

  void _onTap() {
    _haptic();
    _doAction(() => _state.rotate());
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    // Calculate cell size to fit board in screen
    final maxBoardH = screenH * 0.56;
    final maxBoardW = screenW * 0.58;
    final cellByH = maxBoardH / boardRows;
    final cellByW = maxBoardW / boardCols;
    final cellSize = cellByH < cellByW ? cellByH : cellByW;

    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left panel: Hold + Score
                  SizedBox(
                    width: (screenW - cellSize * boardCols) / 2 - 4,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: _buildLeftPanel(),
                    ),
                  ),
                  // Board with gesture detection
                  GestureDetector(
                    onTap: _onTap,
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        BoardWidget(state: _state, cellSize: cellSize),
                        if (_state.isPaused) _buildPauseOverlay(cellSize),
                        if (_state.isOver) _buildGameOverOverlay(cellSize),
                      ],
                    ),
                  ),
                  // Right panel: Next pieces
                  SizedBox(
                    width: (screenW - cellSize * boardCols) / 2 - 4,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: _buildRightPanel(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ControlsWidget(
              onLeft: () { _haptic(); _doAction(() => _state.moveLeft()); },
              onRight: () { _haptic(); _doAction(() => _state.moveRight()); },
              onRotate: () { _haptic(); _doAction(() => _state.rotate()); },
              onSoftDrop: () { _haptic(); _doAction(() => _state.softDrop()); },
              onHardDrop: () { _haptic(); _doAction(() => _state.hardDrop()); },
              onHold: () { _haptic(); _doAction(() => _state.hold()); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TETRIS',
            style: TextStyle(
              color: Colors.cyanAccent.withValues(alpha:0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          IconButton(
            icon: Icon(
              _state.isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white70,
            ),
            onPressed: () => _doAction(() => _state.togglePause()),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildStat('SCORE', _state.score.toString()),
        const SizedBox(height: 12),
        _buildStat('BEST', _highScore.toString()),
        const SizedBox(height: 12),
        _buildStat('LEVEL', _state.level.toString()),
        const SizedBox(height: 12),
        _buildStat('LINES', _state.lines.toString()),
        const SizedBox(height: 16),
        const Text(
          'HOLD',
          style: TextStyle(
            color: Color(0xFF8899BB),
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D22),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334466)),
          ),
          child: _state.held != null
              ? Center(
                  child: PiecePreviewWidget(
                    type: _state.held!.type,
                    cellSize: 12,
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'NEXT',
          style: TextStyle(
            color: Color(0xFF8899BB),
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        ..._state.nextPieces.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: 60,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334466)),
                ),
                child: Center(
                  child: PiecePreviewWidget(type: type, cellSize: 11),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8899BB),
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPauseOverlay(double cellSize) {
    return Container(
      width: cellSize * boardCols,
      height: cellSize * boardRows,
      color: Colors.black.withValues(alpha:0.7),
      child: const Center(
        child: Text(
          'PAUSED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(double cellSize) {
    return Container(
      width: cellSize * boardCols,
      height: cellSize * boardRows,
      color: Colors.black.withValues(alpha:0.8),
      child: const Center(
        child: Text(
          'GAME\nOVER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
