import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/song_model.dart';
import '../data/services/player_service.dart';
import 'history_provider.dart';

/// The app's transport/queue brain. Wraps [PlayerService], keeps shuffle and
/// repeat state, remembers the last played song + position across restarts,
/// and notifies [HistoryProvider] whenever a new track starts.
class PlayerProvider extends ChangeNotifier {
  static const _kLastSongId = 'last_song_id';
  static const _kLastPositionMs = 'last_position_ms';

  final PlayerService _playerService = PlayerService();
  final HistoryProvider historyProvider;

  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  double _speed = 1.0;
  bool _isBuffering = false;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;

  PlayerProvider({required this.historyProvider}) {
    _playerStateSub = _playerService.playerStateStream.listen((state) {
      _isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    });

    // Periodically persist playback position so we can resume later.
    _positionSub = _playerService.positionStream.listen((pos) {
      _debouncedPersistPosition(pos);
    });
  }

  List<Song> get queue => _playerService.queue;
  Song? get currentSong => _playerService.currentSong;
  bool get isPlaying => _playerService.isPlaying;
  bool get isBuffering => _isBuffering;
  bool get shuffleEnabled => _shuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  double get speed => _speed;

  Stream<Duration> get positionStream => _playerService.positionStream;
  Stream<Duration?> get durationStream => _playerService.durationStream;

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    await _playerService.setQueue(songs, startIndex: startIndex);
    await _playerService.setLoopMode(_repeatMode);
    await _playerService.setSpeed(_speed);
    await _playerService.play();
    _onTrackStarted();
  }

  Future<void> playPause() async {
    await _playerService.playPause();
    notifyListeners();
  }

  Future<void> next() async {
    await _playerService.next(shuffle: _shuffleEnabled);
    _onTrackStarted();
  }

  Future<void> previous() async {
    await _playerService.previous();
    _onTrackStarted();
  }

  Future<void> playAt(int index) async {
    await _playerService.playAt(index);
    _onTrackStarted();
  }

  Future<void> seek(Duration position) => _playerService.seek(position);

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    _repeatMode = switch (_repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    await _playerService.setLoopMode(_repeatMode);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _playerService.setSpeed(speed);
    notifyListeners();
  }

  void setSleepTimer(Duration duration) {
    _playerService.setSleepTimer(duration, onFinish: () {
      notifyListeners();
    });
  }

  void cancelSleepTimer() => _playerService.cancelSleepTimer();

  void _onTrackStarted() {
    final song = currentSong;
    if (song != null) {
      historyProvider.recordPlay(song.id);
      _persistLastSong(song.id);
    }
    notifyListeners();
  }

  void _handleTrackCompleted() {
    if (_repeatMode == RepeatMode.one) {
      _playerService.seek(Duration.zero);
      _playerService.play();
    } else {
      next();
    }
  }

  Timer? _persistDebounce;
  void _debouncedPersistPosition(Duration pos) {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastPositionMs, pos.inMilliseconds);
    });
  }

  Future<void> _persistLastSong(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastSongId, songId);
  }

  /// Call at startup (after the library has finished scanning) to resume the
  /// last played song at the last saved position, paused.
  Future<void> restoreLastSession(List<Song> allSongs) async {
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getInt(_kLastSongId);
    final lastPosMs = prefs.getInt(_kLastPositionMs) ?? 0;
    if (lastId == null) return;

    final index = allSongs.indexWhere((s) => s.id == lastId);
    if (index == -1) return;

    await _playerService.setQueue(allSongs, startIndex: index);
    await _playerService.seek(Duration(milliseconds: lastPosMs));
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _persistDebounce?.cancel();
    _playerService.dispose();
    super.dispose();
  }
}
