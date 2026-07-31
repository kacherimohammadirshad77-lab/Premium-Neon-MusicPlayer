import 'package:on_audio_query/on_audio_query.dart';

/// A thin, app-level wrapper around [SongModel] from on_audio_query so the
/// rest of the app never depends directly on the plugin's types. Makes it
/// trivial to swap the scanning backend later without touching UI code.
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int albumId;
  final Duration duration;
  final String filePath;
  final String? folderPath;
  final int sizeBytes;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumId,
    required this.duration,
    required this.filePath,
    required this.folderPath,
    required this.sizeBytes,
  });

  factory Song.fromAudioQuery(SongModel model) {
    return Song(
      id: model.id,
      title: model.title,
      artist: (model.artist == null || model.artist == '<unknown>')
          ? 'Unknown Artist'
          : model.artist!,
      album: (model.album == null || model.album == '<unknown>')
          ? 'Unknown Album'
          : model.album!,
      albumId: model.albumId ?? -1,
      duration: Duration(milliseconds: model.duration ?? 0),
      filePath: model.data,
      folderPath: model.data.contains('/')
          ? model.data.substring(0, model.data.lastIndexOf('/'))
          : null,
      sizeBytes: model.size,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'albumId': albumId,
        'durationMs': duration.inMilliseconds,
        'filePath': filePath,
        'folderPath': folderPath,
        'sizeBytes': sizeBytes,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        albumId: json['albumId'],
        duration: Duration(milliseconds: json['durationMs']),
        filePath: json['filePath'],
        folderPath: json['folderPath'],
        sizeBytes: json['sizeBytes'] ?? 0,
      );
}

/// A user-created playlist. Song membership is stored as a list of song ids
/// so playlists stay valid even if the underlying media store re-scans.
class Playlist {
  final String id;
  String name;
  List<int> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        songIds: List<int>.from(json['songIds']),
        createdAt: DateTime.parse(json['createdAt']),
      );
}

/// Tracks a single "play" event for recently-played / most-played stats.
class PlayHistoryEntry {
  final int songId;
  final DateTime lastPlayedAt;
  final int playCount;

  PlayHistoryEntry({
    required this.songId,
    required this.lastPlayedAt,
    required this.playCount,
  });

  PlayHistoryEntry copyWith({DateTime? lastPlayedAt, int? playCount}) =>
      PlayHistoryEntry(
        songId: songId,
        lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
        playCount: playCount ?? this.playCount,
      );

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'lastPlayedAt': lastPlayedAt.toIso8601String(),
        'playCount': playCount,
      };

  factory PlayHistoryEntry.fromJson(Map<String, dynamic> json) =>
      PlayHistoryEntry(
        songId: json['songId'],
        lastPlayedAt: DateTime.parse(json['lastPlayedAt']),
        playCount: json['playCount'],
      );
}
