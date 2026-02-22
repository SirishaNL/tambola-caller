import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('tambola_dark_mode') ?? false;
    final sound = prefs.getBool('tambola_sound') ?? true;
    final themeId = prefs.getString('tambola_theme') ?? 'orange';
    TtsService().enabled = sound;
    runApp(TambolaApp(initialDark: dark, initialSound: sound, initialThemeId: themeId));
  } catch (e, stack) {
    runApp(_ErrorApp('$e', '$stack'));
  }
}

class _ErrorApp extends StatelessWidget {
  final String error;
  final String stackTrace;

  const _ErrorApp(this.error, this.stackTrace);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Startup error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SelectableText(error),
                const SizedBox(height: 16),
                SelectableText(stackTrace, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
