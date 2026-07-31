import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks favourite song ids and persists them to SharedPreferences.
class FavoritesProvider extends ChangeNotifier {
  static const _kKey = 'favorite_song_ids';

  final Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => _favoriteIds;

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      final list = List<int>.from(jsonDecode(raw));
      _favoriteIds
        ..clear()
        ..addAll(list);
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_favoriteIds.toList()));
  }

  Future<void> toggle(int songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    notifyListeners();
    await _persist();
  }
}
