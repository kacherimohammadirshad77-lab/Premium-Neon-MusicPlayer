import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

/// Central theme engine. Persists the selected theme, dark mode, AMOLED
/// mode, and animation toggle to SharedPreferences so the choice survives
/// app restarts.
class ThemeProvider extends ChangeNotifier {
  static const _kThemeId = 'selected_theme_id';
  static const _kAmoled = 'amoled_mode';
  static const _kAnimations = 'animations_enabled';
  static const _kAlbumArtQuality = 'album_art_quality'; // low | medium | high

  NeonTheme _theme = AppThemes.skyBlueNeon;
  bool _amoledMode = false;
  bool _animationsEnabled = true;
  String _albumArtQuality = 'high';
  bool _loaded = false;

  NeonTheme get theme => _theme;
  bool get amoledMode => _amoledMode;
  bool get animationsEnabled => _animationsEnabled;
  String get albumArtQuality => _albumArtQuality;
  bool get isLoaded => _loaded;

  ThemeData get themeData {
    if (_amoledMode && !_theme.isAmoled) {
      final amoled = NeonTheme(
        id: _theme.id,
        name: _theme.name,
        background: Colors.black,
        surface: Colors.black,
        primary: _theme.primary,
        secondary: _theme.secondary,
        onSurface: _theme.onSurface,
        isAmoled: true,
      );
      return AppThemes.buildThemeData(amoled);
    }
    return AppThemes.buildThemeData(_theme);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kThemeId) ?? AppThemes.skyBlueNeon.id;
    _theme = AppThemes.byId(id);
    _amoledMode = prefs.getBool(_kAmoled) ?? false;
    _animationsEnabled = prefs.getBool(_kAnimations) ?? true;
    _albumArtQuality = prefs.getString(_kAlbumArtQuality) ?? 'high';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setTheme(NeonTheme theme) async {
    _theme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeId, theme.id);
  }

  Future<void> setAmoledMode(bool value) async {
    _amoledMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAmoled, value);
  }

  Future<void> setAnimationsEnabled(bool value) async {
    _animationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAnimations, value);
  }

  Future<void> setAlbumArtQuality(String value) async {
    _albumArtQuality = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAlbumArtQuality, value);
  }
}
