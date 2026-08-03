import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection_result.dart';

class LocalHistoryService {
  static const _legacyKey = 'detection_history';
  static const _limit = 50;

  String userScope({required String userId, required String email}) {
    if (userId.trim().isNotEmpty) return _safe(userId);
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return 'anonymous_device';
    return base64Url.encode(utf8.encode(normalized)).replaceAll('=', '');
  }

  Future<List<DetectionResult>> getHistory({
    required String userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'detection_history_${userScope(userId: userId, email: email)}';
    await _migrate(prefs, key);
    final history = <DetectionResult>[];
    for (final item in prefs.getStringList(key) ?? const <String>[]) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) {
          history.add(
              DetectionResult.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {/* skip one corrupt entry */}
    }
    history.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return history.take(_limit).toList();
  }

  Future<void> saveResult(
    DetectionResult result, {
    required String userId,
    required String email,
  }) async {
    if (!result.isDetected) return;
    final scope = userScope(userId: userId, email: email);
    final prefs = await SharedPreferences.getInstance();
    final key = 'detection_history_$scope';
    await _migrate(prefs, key);
    var stored = result;
    if (kIsWeb) {
      stored = result.copyWith(imageBytes: Uint8List(0));
    } else if (result.imagePath != null && result.imagePath!.isNotEmpty) {
      try {
        final documents = await getApplicationDocumentsDirectory();
        final directory = Directory(
            p.join(documents.path, 'coffee_quality', 'history', scope));
        await directory.create(recursive: true);
        if (!p.isWithin(directory.path, result.imagePath!)) {
          final extension = p.extension(result.imagePath!).toLowerCase();
          final safeExtension =
              const ['.jpg', '.jpeg', '.png'].contains(extension)
                  ? extension
                  : '.jpg';
          final destination =
              p.join(directory.path, '${result.id}$safeExtension');
          await File(result.imagePath!).copy(destination);
          stored =
              result.copyWith(imagePath: destination, imageBytes: Uint8List(0));
        }
      } catch (_) {
        stored = result.copyWith(imageBytes: Uint8List(0));
      }
    }
    final existing = await getHistory(userId: userId, email: email);
    final unique = [stored, ...existing.where((item) => item.id != stored.id)]
        .take(_limit)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(key, unique);
  }

  Future<void> _migrate(SharedPreferences prefs, String target) async {
    final legacy = prefs.getStringList(_legacyKey);
    if (legacy == null) return;
    final current = prefs.getStringList(target) ?? const <String>[];
    await prefs.setStringList(
        target, [...current, ...legacy].take(_limit).toList());
    await prefs.remove(_legacyKey);
  }

  static String _safe(String value) =>
      value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}
