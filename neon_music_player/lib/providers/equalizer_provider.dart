import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Band-level equalizer state + presets.
///
/// IMPORTANT LIMITATION: just_audio does not expose a cross-platform, raw
/// PCM equalizer API. A production-grade EQ needs a native Android
/// AudioEffect (android.media.audiofx.Equalizer) reached through a platform
/// channel, which is outside what a pure-Dart/Flutter package can do. This
/// provider models the full preset/slider UI and persists user choices so
/// the native layer can be wired in later without changing any UI code —
/// but the sliders do not yet change the audible sound.
class EqualizerPreset {
  final String name;
  final List<double> bandsDb; // e.g. 5 or 10 bands, -12..+12 dB

  const EqualizerPreset(this.name, this.bandsDb);
}

class EqualizerProvider extends ChangeNotifier {
  static const _kSelectedPreset = 'eq_preset_name';
  static const _kCustomBands = 'eq_custom_bands';
  static const bandLabels = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];

  static const presets = <EqualizerPreset>[
    EqualizerPreset('Normal', [0, 0, 0, 0, 0]),
    EqualizerPreset('Rock', [5, 3, -2, 3, 5]),
    EqualizerPreset('Pop', [-1, 2, 4, 2, -1]),
    EqualizerPreset('Jazz', [3, 2, -1, 2, 3]),
    EqualizerPreset('Classical', [4, 3, 0, 2, 4]),
    EqualizerPreset('Dance', [6, 2, 0, 3, 5]),
    EqualizerPreset('Bass Boost', [8, 6, 0, 0, 0]),
    EqualizerPreset('Treble Boost', [0, 0, 0, 6, 8]),
  ];

  String _selectedPresetName = 'Normal';
  List<double> _customBands = List.filled(5, 0.0);
  bool _enabled = false;

  String get selectedPresetName => _selectedPresetName;
  bool get enabled => _enabled;

  List<double> get activeBands {
    if (_selectedPresetName == 'Custom') return _customBands;
    return presets.firstWhere((p) => p.name == _selectedPresetName).bandsDb;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedPresetName = prefs.getString(_kSelectedPreset) ?? 'Normal';
    final raw = prefs.getString(_kCustomBands);
    if (raw != null) {
      _customBands = List<double>.from(jsonDecode(raw));
    }
    notifyListeners();
  }

  Future<void> selectPreset(String name) async {
    _selectedPresetName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedPreset, name);
  }

  Future<void> setCustomBand(int index, double valueDb) async {
    _customBands[index] = valueDb;
    _selectedPresetName = 'Custom';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCustomBands, jsonEncode(_customBands));
    await prefs.setString(_kSelectedPreset, 'Custom');
  }

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }
}
