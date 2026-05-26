import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 40),
              if (isNewHighScore) ...[
                const Text(
                  '🏆 NEW HIGH SCORE!',
                  style: TextStyle(
                    color: Color(0xFFFFCC00),
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _statRow('SCORE', score.toString()),
              const SizedBox(height: 8),
              _statRow('BEST', highScore.toString()),
              const SizedBox(height: 52),
              _actionButton('PLAY AGAIN', const Color(0xFF00AAAA), onRestart),
              const SizedBox(height: 16),
              _actionButton('HOME', const Color(0xFF334466), onHome),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF8899BB), fontSize: 14, letterSpacing: 1),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 100,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
