import 'dart:async';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';

/// Widget that displays text with word-by-word highlighting during TTS playback.
/// Each word is wrapped in a highlight container that animates when spoken.
class SpeakingText extends StatefulWidget {
  final String text;
  final TextStyle? baseStyle;
  final TextStyle? highlightStyle;
  final TextAlign textAlign;
  final TtsService ttsService;

  const SpeakingText({
    super.key,
    required this.text,
    this.baseStyle,
    this.highlightStyle,
    this.textAlign = TextAlign.center,
    required this.ttsService,
  });

  @override
  State<SpeakingText> createState() => _SpeakingTextState();
}

class _SpeakingTextState extends State<SpeakingText>
    with SingleTickerProviderStateMixin {
  int _highlightedWordIndex = -1;
  Timer? _highlightTimer;
  List<String> _words = [];
  final List<double> _wordDurations = [];

  // Approximate speaking duration per character (ms) at 0.575 speed
  static const double _msPerChar = 50.0;

  @override
  void initState() {
    super.initState();
    _words = _splitIntoWords(widget.text);
    _calculateWordDurations();
    widget.ttsService.setProgressCallback(_onWordSpoken);
  }

  @override
  void didUpdateWidget(SpeakingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _words = _splitIntoWords(widget.text);
      _calculateWordDurations();
    }
    if (oldWidget.ttsService != widget.ttsService) {
      oldWidget.ttsService.setProgressCallback(null);
      widget.ttsService.setProgressCallback(_onWordSpoken);
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    widget.ttsService.setProgressCallback(null);
    super.dispose();
  }

  /// Split text into words while preserving word boundaries
  List<String> _splitIntoWords(String text) {
    // Split by whitespace but keep the words
    return text.split(RegExp(r'\s+'));
  }

  /// Calculate approximate duration for each word based on character count
  void _calculateWordDurations() {
    _wordDurations.clear();
    for (final word in _words) {
      // Duration = word length * msPerChar + base pause
      final duration = word.length * _msPerChar + 100; // +100ms for word pause
      _wordDurations.add(duration);
    }
  }

  void _onWordSpoken(String word, int index, int total) {
    if (!mounted) return;

    // Find which word index matches the spoken word
    int matchingIndex = -1;
    for (int i = 0; i < _words.length; i++) {
      // Case-insensitive comparison, stripping punctuation
      if (_words[i].toLowerCase().replaceAll(RegExp(r'[^\w]'), '') ==
          word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '')) {
        matchingIndex = i;
        break;
      }
    }

    if (matchingIndex >= 0) {
      setState(() {
        _highlightedWordIndex = matchingIndex;
      });

      // Clear highlight after word duration
      _highlightTimer?.cancel();
      _highlightTimer = Timer(
        Duration(milliseconds: _wordDurations[matchingIndex].toInt()),
        () {
          if (mounted) {
            setState(() {
              _highlightedWordIndex = -1;
            });
          }
        },
      );
    }
  }

  void _startSpeaking() {
    widget.ttsService.speak(widget.text);

    // Auto-clear after estimated total duration
    final totalDuration = _wordDurations.fold<double>(
      0,
      (sum, duration) => sum + duration,
    );
    _highlightTimer?.cancel();
    _highlightTimer = Timer(
      Duration(milliseconds: totalDuration.toInt() + 500),
      () {
        if (mounted) {
          setState(() {
            _highlightedWordIndex = -1;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultHighlightStyle = (widget.baseStyle ?? const TextStyle()).merge(
      TextStyle(
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
        decorationColor: Colors.deepPurple,
        decorationThickness: 2,
      ),
    );

    return Wrap(
      alignment: _getWrapAlignment(),
      spacing: 4,
      runSpacing: 8,
      children: _words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        final isHighlighted = index == _highlightedWordIndex;

        return _WordHighlight(
          word: word,
          isHighlighted: isHighlighted,
          baseStyle: widget.baseStyle,
          highlightStyle: widget.highlightStyle ?? defaultHighlightStyle,
          onTap: _startSpeaking,
        );
      }).toList(),
    );
  }

  WrapAlignment _getWrapAlignment() {
    switch (widget.textAlign) {
      case TextAlign.left:
        return WrapAlignment.start;
      case TextAlign.right:
        return WrapAlignment.end;
      case TextAlign.center:
      default:
        return WrapAlignment.center;
    }
  }
}

/// Individual word widget with highlight animation
class _WordHighlight extends StatelessWidget {
  final String word;
  final bool isHighlighted;
  final TextStyle? baseStyle;
  final TextStyle highlightStyle;
  final VoidCallback onTap;

  const _WordHighlight({
    required this.word,
    required this.isHighlighted,
    this.baseStyle,
    required this.highlightStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: isHighlighted ? 8 : 4,
        vertical: isHighlighted ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.deepPurple.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: Colors.deepPurple, width: 1.5)
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Text(
          word,
          style: isHighlighted ? highlightStyle : baseStyle,
        ),
      ),
    );
  }
}
