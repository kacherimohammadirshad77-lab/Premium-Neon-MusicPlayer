import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

enum RepeatMode { off, one, all }

/// Thin wrapper around just_audio's [AudioPlayer] that exposes exactly what
/// the app's UI/providers need: a queue, transport controls, speed, and
/// looping — plus streams the UI can listen to directly.
class PlayerService {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _queue = [];
  int _currentIndex = 0;

  AudioPlayer get rawPlayer => _player;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isEmpty ? null : _queue[_currentIndex];

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get isPlaying => _player.playing;

  Future<void> setQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue = songs;
    _currentIndex = startIndex;
    await _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final song = currentSong;
    if (song == null) return;
    await _player.setFilePath(song.filePath);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> playPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next({bool shuffle = false}) async {
    if (_queue.isEmpty) return;
    if (shuffle) {
      _currentIndex = (_queue.toList()..shuffle()).isEmpty
          ? _currentIndex
          : (DateTime.now().millisecondsSinceEpoch % _queue.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    await _loadCurrent();
    await play();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await _loadCurrent();
    await play();
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await _loadCurrent();
    await play();
  }

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  /// just_audio does not expose true pitch-shifting on all platforms without
  /// a native plugin extension; this sets playback speed only. A real pitch
  /// control would need a platform channel to Android's AudioEffect API.
  Future<void> setPitch(double pitch) async {
    // Intentionally a no-op placeholder — see class doc above.
  }

  Future<void> setLoopMode(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return _player.setLoopMode(LoopMode.off);
      case RepeatMode.one:
        return _player.setLoopMode(LoopMode.one);
      case RepeatMode.all:
        return _player.setLoopMode(LoopMode.all);
    }
  }

  Timer? _sleepTimer;
  void setSleepTimer(Duration duration, {required VoidCallback onFinish}) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, () {
      pause();
      onFinish();
    });
  }

  void cancelSleepTimer() => _sleepTimer?.cancel();

  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
  }
}

typedef VoidCallback = void Function();
