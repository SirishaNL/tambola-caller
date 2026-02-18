import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech: announces the called number as a single clear word (e.g. "forty-eight").
/// Uses words for all 1–90 so the engine never reads "48" as "four eight".
/// On iOS, sets audio category to playback so TTS is audible (not silenced by lock/silent switch).
class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;
  double _speechRate = 0.5; // 0.0–1.0; middle is normal
  bool _iosAudioConfigured = false;

  bool get enabled => _enabled;
  double get speechRate => _speechRate;

  set enabled(bool value) {
    _enabled = value;
  }

  /// speechRate: 0.0 = slowest, 0.5 = normal, 1.0 = fastest (platform-dependent).
  set speechRate(double value) {
    _speechRate = value.clamp(0.0, 1.0);
  }

  static const List<String> _ones = [
    'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
  ];
  static const List<String> _teens = [
    'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
    'sixteen', 'seventeen', 'eighteen', 'nineteen'
  ];
  static const List<String> _tens = [
    '', '', 'twenty', 'thirty', 'forty', 'fifty',
    'sixty', 'seventy', 'eighty', 'ninety'
  ];

  /// Number as one word (1–90). e.g. 48 → "forty-eight", 8 → "eight".
  String _numberToWord(int n) {
    if (n >= 1 && n <= 9) return _ones[n - 1];
    if (n >= 10 && n <= 19) return _teens[n - 10];
    if (n >= 20 && n <= 90) {
      final t = n ~/ 10;
      final o = n % 10;
      if (o == 0) return _tens[t];
      return '${_tens[t]}-${_ones[o - 1]}';
    }
    return n.toString();
  }

  Future<void> _configureIosAudioIfNeeded() async {
    if (_iosAudioConfigured) return;
    try {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [],
      );
    } catch (_) {
      // Not iOS or option not supported; ignore.
    }
    _iosAudioConfigured = true;
  }

  Future<void> speak(int number) async {
    if (!_enabled) return;
    await _configureIosAudioIfNeeded();
    await _tts.setSpeechRate(0.5 + _speechRate);
    await _tts.speak(_numberToWord(number));
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
