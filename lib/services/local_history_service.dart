import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection_result.dart';

class LocalHistoryService {
  static const _historyKey = 'detection_history';

  Future<List<DetectionResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_historyKey) ?? const [];
    final history = <DetectionResult>[];

    for (final item in encoded) {
      final decoded = jsonDecode(item);
      if (decoded is Map<String, dynamic>) {
        history.add(DetectionResult.fromJson(decoded));
      }
    }

    history.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return history;
  }

  Future<void> saveResult(DetectionResult result) async {
    if (!result.isDetected) return;
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? <String>[];
    history.insert(0, jsonEncode(result.toJson()));
    await prefs.setStringList(_historyKey, history);
  }
}
