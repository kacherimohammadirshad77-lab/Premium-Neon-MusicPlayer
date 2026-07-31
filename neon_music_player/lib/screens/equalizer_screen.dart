import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/equalizer_provider.dart';

/// Equalizer UI with presets and per-band sliders. See the doc comment on
/// [EqualizerProvider] for the current limitation on real audio DSP.
class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eq = context.watch<EqualizerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        actions: [
          Switch(value: eq.enabled, onChanged: eq.setEnabled),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final preset in EqualizerProvider.presets)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(preset.name),
                      selected: eq.selectedPresetName == preset.name,
                      onSelected: (_) => eq.selectPreset(preset.name),
                    ),
                  ),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: eq.selectedPresetName == 'Custom',
                  onSelected: (_) => eq.selectPreset('Custom'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < EqualizerProvider.bandLabels.length; i++)
                  _Band(
                    label: EqualizerProvider.bandLabels[i],
                    value: eq.activeBands[i],
                    onChanged: (v) => eq.setCustomBand(i, v),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Note: EQ presets are saved and ready for a native audio '
              'effect engine. Wiring them to actually change the sound '
              'requires an Android platform channel to android.media.'
              'audiofx.Equalizer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _Band extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _Band({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: value,
              min: -12,
              max: 12,
              onChanged: onChanged,
            ),
          ),
        ),
        Text('${value.toStringAsFixed(0)}dB', style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
