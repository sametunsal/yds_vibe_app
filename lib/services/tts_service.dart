import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  factory TtsService() {
    return _instance;
  }

  TtsService._internal() {
    _flutterTts = FlutterTts();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.575); // 0.5 * 1.15 = 0.575 (15% faster)
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await _ensureInitialized();
    if (text.isNotEmpty) {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
