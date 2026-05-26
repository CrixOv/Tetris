import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/game_over_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070714),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00CFCF),
          secondary: Color(0xFF9F00CF),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

enum AppScreen { home, game, gameOver }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppScreen _screen = AppScreen.home;
  int _highScore = 0;
  int _lastScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _highScore = prefs.getInt('highScore') ?? 0);
  }

  Future<void> _saveHighScore(int score) async {
    if (score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
      setState(() => _highScore = score);
    }
  }

  void _onGameOver(int score) {
    _lastScore = score;
    _saveHighScore(score);
    setState(() => _screen = AppScreen.gameOver);
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case AppScreen.home:
        return HomeScreen(
          highScore: _highScore,
          onPlay: () => setState(() => _screen = AppScreen.game),
        );
      case AppScreen.game:
        return GameScreen(
          highScore: _highScore,
          onGameOver: _onGameOver,
        );
      case AppScreen.gameOver:
        return GameOverScreen(
          score: _lastScore,
          highScore: _highScore,
          isNewHighScore: _lastScore >= _highScore,
          onRestart: () => setState(() => _screen = AppScreen.game),
          onHome: () => setState(() => _screen = AppScreen.home),
        );
    }
  }
}
