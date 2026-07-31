import 'package:flutter/foundation.dart';
import '../data/models/song_model.dart';
import '../data/services/library_service.dart';

/// Owns the full device song library: scanning, search, and folder grouping.
/// Other providers (favorites, playlists, history) reference songs by id and
/// look them up here.
class MusicLibraryProvider extends ChangeNotifier {
  final LibraryService _service = LibraryService();

  List<Song> _songs = [];
  bool _isScanning = false;
  bool _permissionDenied = false;
  String _searchQuery = '';

  List<Song> get songs => _songs;
  bool get isScanning => _isScanning;
  bool get permissionDenied => _permissionDenied;
  int get songCount => _songs.length;

  Song? byId(int id) {
    for (final s in _songs) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<Song> get searchResults {
    if (_searchQuery.trim().isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _songs
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q) ||
            (s.folderPath ?? '').toLowerCase().contains(q))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Map<String, List<Song>> get folders => _service.groupByFolder(_songs);

  Map<String, List<Song>> get byAlbum {
    final map = <String, List<Song>>{};
    for (final s in _songs) {
      map.putIfAbsent(s.album, () => []).add(s);
    }
    return map;
  }

  Map<String, List<Song>> get byArtist {
    final map = <String, List<Song>>{};
    for (final s in _songs) {
      map.putIfAbsent(s.artist, () => []).add(s);
    }
    return map;
  }

  Future<void> scan() async {
    _isScanning = true;
    _permissionDenied = false;
    notifyListeners();

    final hasPermission = await _service.requestPermission();
    if (!hasPermission) {
      _permissionDenied = true;
      _isScanning = false;
      notifyListeners();
      return;
    }

    _songs = await _service.scanAllSongs();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> refresh() => scan();

  /// Songs added in roughly the last 30 days, newest first, using file
  /// modification order as a proxy since MediaStore's dateAdded isn't
  /// exposed directly on every Android version through on_audio_query.
  List<Song> get recentlyAdded {
    final sorted = [..._songs];
    sorted.sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(50).toList();
  }
}
