import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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

/// Manages SRS progress storage with atomic writes and backup recovery.
///
/// Storage layout:
///   progress.json     — current progress (cardId → SRS fields)
///   progress.json.bak — backup of last known good state
///   progress.json.tmp — temp file during atomic write
class ProgressService {
  static const String _fileName = 'progress.json';
  static const String _bakFileName = 'progress.json.bak';
  static const String _tmpFileName = 'progress.json.tmp';

  static String? _cachedPath;

  static Future<String> get _localPath async {
    _cachedPath ??= (await getApplicationDocumentsDirectory()).path;
    return _cachedPath!;
  }

  /// Load progress map from disk.
  /// Recovery chain: main file → .bak → empty map.
  static Future<Map<String, CardProgress>> loadProgress() async {
    final path = await _localPath;
    final mainFile = File('$path/$_fileName');
    final bakFile = File('$path/$_bakFileName');

    // Try main file
    if (await mainFile.exists()) {
      try {
        final data = await mainFile.readAsString();
        final map = _parseProgressJson(data);
        debugPrint(
          '[ProgressService] Loaded ${map.length} card progress entries',
        );
        return map;
      } catch (e) {
        debugPrint('[ProgressService] Main file corrupt: $e');
      }
    }

    // Try backup file
    if (await bakFile.exists()) {
      try {
        final data = await bakFile.readAsString();
        final map = _parseProgressJson(data);
        debugPrint(
          '[ProgressService] Recovered ${map.length} entries from backup',
        );
        // Restore main file from backup
        await bakFile.copy('$path/$_fileName');
        return map;
      } catch (e) {
        debugPrint('[ProgressService] Backup also corrupt: $e');
      }
    }

    // First run or total corruption
    debugPrint('[ProgressService] No progress file found, starting fresh');
    return {};
  }

  /// Save progress map with atomic write + backup.
  static Future<void> saveProgress(Map<String, CardProgress> progress) async {
    final path = await _localPath;
    final mainFile = File('$path/$_fileName');
    final bakFile = File('$path/$_bakFileName');
    final tmpFile = File('$path/$_tmpFileName');

    try {
      // 1. Write to temp file
      final jsonMap = <String, dynamic>{};
      for (final entry in progress.entries) {
        jsonMap[entry.key] = entry.value.toJson();
      }
      final jsonString = json.encode(jsonMap);
      await tmpFile.writeAsString(jsonString, flush: true);

      // 2. Backup current main file (if exists)
      if (await mainFile.exists()) {
        await mainFile.copy(bakFile.path);
      }

      // 3. Rename temp → main (atomic on most filesystems)
      await tmpFile.rename(mainFile.path);

      debugPrint('[ProgressService] Saved ${progress.length} entries (atomic)');
    } catch (e) {
      debugPrint('[ProgressService] Error saving progress: $e');
      // Clean up temp file if it exists
      if (await tmpFile.exists()) {
        await tmpFile.delete();
      }
    }
  }

  /// Update a single card's progress and save atomically.
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
        // Unknown or malformed entry — skip gracefully
        debugPrint(
          '[ProgressService] Skipping corrupt entry "${entry.key}": $e',
        );
      }
    }
    return result;
  }
}
