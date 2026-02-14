import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SRS progress data for a single card.
class CardProgress {
  final double easeFactor;
  final int intervalDays;
  final DateTime dueDate;
  final int repetitions;
  final DateTime? lastReviewed;

  const CardProgress({
    required this.easeFactor,
    required this.intervalDays,
    required this.dueDate,
    required this.repetitions,
    this.lastReviewed,
  });

  Map<String, dynamic> toJson() => {
    'easeFactor': easeFactor,
    'intervalDays': intervalDays,
    'dueDate': dueDate.toIso8601String(),
    'repetitions': repetitions,
    'lastReviewed': lastReviewed?.toIso8601String(),
  };

  factory CardProgress.fromJson(Map<String, dynamic> json) {
    return CardProgress(
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: json['intervalDays'] as int? ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String).toLocal()
          : DateTime.now(),
      repetitions: json['repetitions'] as int? ?? 0,
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.parse(json['lastReviewed'] as String).toLocal()
          : null,
    );
  }
}

/// Cross-platform SRS progress storage using SharedPreferences.
///
/// Stores progress as a single JSON string under key `progress_json`.
/// Works identically on Web, Mobile, and Desktop.
class ProgressService {
  static const String _prefsKey = 'progress_json';

  /// Load progress map. Returns empty map on any failure.
  static Future<Map<String, CardProgress>> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) {
        debugPrint('[ProgressService] No saved progress, starting fresh');
        return {};
      }
      final map = _parseProgressJson(raw);
      debugPrint(
        '[ProgressService] Loaded ${map.length} card progress entries',
      );
      return map;
    } catch (e) {
      debugPrint('[ProgressService] loadProgress failed: $e');
      return {};
    }
  }

  /// Save progress map. Errors are logged but never thrown.
  static Future<void> saveProgress(Map<String, CardProgress> progress) async {
    try {
      final jsonMap = <String, dynamic>{};
      for (final entry in progress.entries) {
        jsonMap[entry.key] = entry.value.toJson();
      }
      final jsonString = json.encode(jsonMap);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonString);
      debugPrint('[ProgressService] Saved ${progress.length} entries');
    } catch (e) {
      debugPrint('[ProgressService] Error saving progress: $e');
    }
  }

  /// Update a single card's progress and persist.
  static Future<void> updateCardProgress(
    String cardId,
    CardProgress progress,
    Map<String, CardProgress> allProgress,
  ) async {
    allProgress[cardId] = progress;
    await saveProgress(allProgress);
  }

  static Map<String, CardProgress> _parseProgressJson(String data) {
    final decoded = json.decode(data) as Map<String, dynamic>;
    final result = <String, CardProgress>{};
    for (final entry in decoded.entries) {
      try {
        result[entry.key] = CardProgress.fromJson(
          entry.value as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint(
          '[ProgressService] Skipping corrupt entry "${entry.key}": $e',
        );
      }
    }
    return result;
  }
}
