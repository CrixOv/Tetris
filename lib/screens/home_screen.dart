import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final int highScore;
  final VoidCallback onPlay;

  const HomeScreen({super.key, required this.highScore, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00CFCF), Color(0xFF9F00CF)],
                ).createShader(bounds),
                child: const Text(
                  'TETRIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // High score
              if (highScore > 0) ...[
                const Text(
                  'BEST SCORE',
                  style: TextStyle(
                    color: Color(0xFF8899BB),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  highScore.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              // Play button
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00AAAA), Color(0xFF7700AA)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00CFCF).withValues(alpha:0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Controls hint
              const Text(
                'TAP board to rotate  •  SWIPE to move\nSWIPE DOWN to drop  •  Use buttons below',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF445566),
                  fontSize: 12,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
