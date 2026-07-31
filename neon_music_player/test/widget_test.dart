import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_music_player/main.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (tester) async {
    await tester.pumpWidget(const NeonMusicApp());

    // The splash screen renders immediately; the dashboard behind it needs
    // a real Android/iOS platform (audio + permission plugins), so this
    // smoke test intentionally stops at "did the app build without
    // throwing" rather than pumping past the splash delay.
    expect(find.text('NEON MUSIC'), findsOneWidget);
  });
}
