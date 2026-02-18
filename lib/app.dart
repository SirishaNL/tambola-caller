import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/tts_service.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';

class TambolaApp extends StatefulWidget {
  final bool initialDark;
  final bool initialSound;
  final String initialThemeId;

  const TambolaApp({
    super.key,
    this.initialDark = false,
    this.initialSound = true,
    this.initialThemeId = themeOrange,
  });

  @override
  State<TambolaApp> createState() => _TambolaAppState();
}

class _TambolaAppState extends State<TambolaApp> {
  late bool _darkMode;
  late bool _soundOn;
  late String _themeId;
  bool _showGame = false;
  bool _resumedGame = false;
  bool _gameManual = true;
  int _gameIntervalSeconds = 5;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDark;
    _soundOn = widget.initialSound;
    _themeId = widget.initialThemeId;
  }

  void _setTheme(String themeId) {
    setState(() => _themeId = themeId);
    SharedPreferences.getInstance().then((p) => p.setString('tambola_theme', themeId));
  }

  void _toggleDarkMode() {
    setState(() {
      _darkMode = !_darkMode;
      SharedPreferences.getInstance().then((p) => p.setBool('tambola_dark_mode', _darkMode));
    });
  }

  void _toggleSound() {
    setState(() {
      _soundOn = !_soundOn;
      TtsService().enabled = _soundOn;
      SharedPreferences.getInstance().then((p) => p.setBool('tambola_sound', _soundOn));
    });
  }

  void _openGame({bool resume = false, bool? isManual, int? intervalSeconds}) {
    setState(() {
      _showGame = true;
      _resumedGame = resume;
      if (isManual != null) _gameManual = isManual;
      if (intervalSeconds != null) _gameIntervalSeconds = intervalSeconds;
    });
  }

  void _closeGame() {
    setState(() {
      _showGame = false;
      _resumedGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tambola Caller',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: getTheme(_themeId, false),
      darkTheme: getTheme(_themeId, true),
      home: _showGame
          ? GameScreen(
              resumed: _resumedGame,
              isManual: _gameManual,
              intervalSeconds: _gameIntervalSeconds,
              onExit: _closeGame,
              darkMode: _darkMode,
              soundOn: _soundOn,
              onToggleDark: _toggleDarkMode,
              onToggleSound: _toggleSound,
              themeId: _themeId,
              onThemeChanged: _setTheme,
            )
          : HomeScreen(
              onNewGame: _openGame,
              onResume: () => _openGame(resume: true),
              darkMode: _darkMode,
              soundOn: _soundOn,
              onToggleDark: _toggleDarkMode,
              onToggleSound: _toggleSound,
              themeId: _themeId,
              onThemeChanged: _setTheme,
            ),
    );
  }
}
