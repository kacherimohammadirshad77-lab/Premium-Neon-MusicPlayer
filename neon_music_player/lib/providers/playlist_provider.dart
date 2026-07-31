import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/song_model.dart';

/// Manages user-created playlists: create, rename, delete, add/remove/reorder
/// songs. Persists everything as JSON in SharedPreferences.
class PlaylistProvider extends ChangeNotifier {
  static const _kKey = 'playlists_json';
  final _uuid = const Uuid();

  List<Playlist> _playlists = [];

  /// Newest playlists first, per the spec.
  List<Playlist> get playlists =>
      [..._playlists]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _playlists = list.map((e) => Playlist.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      jsonEncode(_playlists.map((p) => p.toJson()).toList()),
    );
  }

  Future<Playlist> create(String name) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    _playlists.add(playlist);
    notifyListeners();
    await _persist();
    return playlist;
  }

  Future<void> rename(String playlistId, String newName) async {
    final p = _playlists.firstWhere((p) => p.id == playlistId);
    p.name = newName;
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
    await _persist();
  }

  Future<void> addSong(String playlistId, int songId) async {
    final p = _playlists.firstWhere((p) => p.id == playlistId);
    if (!p.songIds.contains(songId)) {
      p.songIds.add(songId);
      notifyListeners();
      await _persist();
    }
  }

  Future<void> removeSong(String playlistId, int songId) async {
    final p = _playlists.firstWhere((p) => p.id == playlistId);
    p.songIds.remove(songId);
    notifyListeners();
    await _persist();
  }

  Future<void> reorderSongs(String playlistId, int oldIndex, int newIndex) async {
    final p = _playlists.firstWhere((p) => p.id == playlistId);
    if (newIndex > oldIndex) newIndex -= 1;
    final id = p.songIds.removeAt(oldIndex);
    p.songIds.insert(newIndex, id);
    notifyListeners();
    await _persist();
  }

  /// Exports every playlist as a JSON string, for the Settings > Backup
  /// Playlists feature. The caller decides where to write/share it.
  String exportBackup() =>
      jsonEncode(_playlists.map((p) => p.toJson()).toList());

  /// Restores playlists from a previously exported JSON string, merging with
  /// (not replacing) whatever already exists.
  Future<void> restoreBackup(String json) async {
    final list = jsonDecode(json) as List;
    final restored = list.map((e) => Playlist.fromJson(e)).toList();
    for (final r in restored) {
      if (!_playlists.any((p) => p.id == r.id)) {
        _playlists.add(r);
      }
    }
    notifyListeners();
    await _persist();
  }
}
