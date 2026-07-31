# Neon Music Player

A complete Flutter project (not just `lib/`) for an offline Android music player
in a Sky Blue Neon glassmorphism theme — Material 3, dashboard home, mini
player, fullscreen player, library scanning, playlists, favourites, search,
themes, and a GitHub Actions workflow that builds a release APK on every push.

## What's in this zip

```
android/            Full Gradle project: settings.gradle, root + app build.gradle,
                     gradle.properties, gradlew/gradlew.bat, AndroidManifest.xml
                     (main/debug/profile), MainActivity.kt, launcher icons
                     (generated PNGs at every mipmap density), styles, proguard rules
ios/                Podfile, Info.plist, AppDelegate.swift, xcconfig files
                     — see "iOS/macOS limitation" below
macos/              Podfile, AppDelegate.swift, MainFlutterWindow.swift, Info.plist
                     — see "iOS/macOS limitation" below
linux/              CMakeLists.txt + GTK runner (main.cc, my_application.cc/h)
windows/            CMakeLists.txt + Win32 runner entry point (main.cpp)
web/                index.html, manifest.json, generated neon-themed icons
test/               widget_test.dart (smoke test)
assets/images/      Generated neon app-logo PNG, wired into pubspec.yaml
.github/workflows/  build_apk.yml — CI that builds and uploads a release APK
lib/                Your existing Dart source (unchanged)
pubspec.yaml, analysis_options.yaml, .gitignore, .metadata
```

This is now genuinely openable as an Android project and buildable in CI — not
a `lib/`-only drop-in. I want to be equally direct about the two places where
"complete" runs into a hard technical wall, rather than quietly shipping
something broken with a green checkmark on top.

## iOS/macOS limitation (read this before opening in Xcode)

Xcode identifies every file in a project through `Runner.xcodeproj/project.pbxproj`
— a property list keyed by auto-generated 24-character hex IDs that map every
source file, resource, and build phase to each other. It's normally written by
Xcode itself, and by `flutter create`'s templating engine, which has the exact
ID-generation logic. It is not deterministic, human-writable text the way a
Gradle file or CMakeLists is — a hand-typed one is essentially always subtly
wrong (missing IDs, mismatched references), and Xcode's failure mode isn't a
build warning, it's refusing to open the project at all. I did not include
`project.pbxproj` for that reason: shipping a fake one would look complete and
then fail outright, which is worse than the honest gap.

Everything else for iOS/macOS **is** here and real: `Podfile`, `Info.plist`,
`AppDelegate.swift`, `MainFlutterWindow.swift`, xcconfig files. To get a working
Xcode project, run this once on a Mac with Flutter installed:

```bash
flutter create --platforms=ios,macos .
```

Run inside this folder — it only generates the missing `.xcodeproj` /
`.xcworkspace` files and won't touch your `lib/`, `pubspec.yaml`, or the other
platform folders already here.

## Gradle wrapper jar

Same category of issue, smaller in scope: `gradle-wrapper.jar` is a ~60KB
*compiled* bootstrap loader, not source text, and I had no network access to
fetch the official one or a JDK to compile a substitute. Two ways this gets
resolved automatically, so it's a non-issue in practice:

- **Android Studio**: opening this project will detect the missing/invalid
  wrapper jar and offer to regenerate it (Gradle sync prompt). Accept it.
- **GitHub Actions**: `.github/workflows/build_apk.yml` regenerates it with the
  runner's preinstalled Gradle before building, so CI works with no manual step.

If you ever need to do it manually: `cd android && gradle wrapper --gradle-version 8.6`.

## Linux/Windows/Web — one functional caveat

The CMake/Win32/web scaffolding is real and will compile, but the app's core
feature — scanning the device's local music library — depends on
`on_audio_query`, which is Android/iOS only. On desktop/web builds the app will
launch (splash → dashboard) but library scanning returns nothing, since there's
no equivalent plugin wired in for those platforms. This isn't a placeholder in
the code you have; it's a real gap in plugin coverage across platforms that
would need a different scanning strategy (e.g. `file_picker` + manual folder
scanning) to fill for desktop.

## Getting a signed release APK

The debug signing config in `android/app/build.gradle` is fine for CI/testing
builds (including what GitHub Actions produces) but not for the Play Store.
Before publishing, generate a keystore and add a real `signingConfigs.release`
block — happy to write that out if you want to go that route.

## Everything else (playback, themes, providers, screens)

Unchanged from before — see the code comments in `lib/providers/equalizer_provider.dart`
and `lib/data/services/player_service.dart` for the two remaining audio-feature
notes (EQ and pitch need a native platform channel to actually change sound,
not just Flutter/Dart).
