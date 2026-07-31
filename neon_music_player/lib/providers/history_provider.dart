import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/song_model.dart';

/// Tracks play history for the Recently Played and Most Played screens.
/// One entry per song, updated every time a track starts playing.
class HistoryProvider extends ChangeNotifier {
  static const _kKey = 'play_history_json';

  final Map<int, PlayHistoryEntry> _entries = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        final entry = PlayHistoryEntry.fromJson(e);
        _entries[entry.songId] = entry;
      }
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      jsonEncode(_entries.values.map((e) => e.toJson()).toList()),
    );
  }

  /// Call this whenever a song starts playing.
  Future<void> recordPlay(int songId) async {
    final existing = _entries[songId];
    _entries[songId] = existing == null
        ? PlayHistoryEntry(
            songId: songId, lastPlayedAt: DateTime.now(), playCount: 1)
        : existing.copyWith(
            lastPlayedAt: DateTime.now(),
            playCount: existing.playCount + 1,
          );
    notifyListeners();
    await _persist();
  }

  int playCountFor(int songId) => _entries[songId]?.playCount ?? 0;
  DateTime? lastPlayedFor(int songId) => _entries[songId]?.lastPlayedAt;

  /// Recently played song ids, most recent first.
  List<int> get recentlyPlayedIds {
    final list = _entries.values.toList()
      ..sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));
    return list.map((e) => e.songId).toList();
  }

  /// Most played song ids, highest play count first.
  List<int> get mostPlayedIds {
    final list = _entries.values.toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));
    return list.map((e) => e.songId).toList();
  }
}
