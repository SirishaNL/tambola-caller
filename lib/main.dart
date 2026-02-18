import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final dark = prefs.getBool('tambola_dark_mode') ?? false;
  final sound = prefs.getBool('tambola_sound') ?? true;
  final themeId = prefs.getString('tambola_theme') ?? 'orange';
  TtsService().enabled = sound;
  runApp(TambolaApp(initialDark: dark, initialSound: sound, initialThemeId: themeId));
}
