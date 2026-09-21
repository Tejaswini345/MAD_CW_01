# CW1 Counter & Image Toggle App

Flutter app for CSC 6370 (Mobile App Development) — Coursework #01. Built for the
graduate track: counter with scale-up features, animated image toggle with a
day/night city, light/dark theme, and SharedPreferences persistence with a
confirmation-gated reset.

## Required Tasks

**Task 1 — Counter**
- Increment / Decrement, with Decrement disabled at 0
- Step selector (+1 / +5 / +10)
- Undo, keeping the last 5 actions
- Counter color shifts from green to red as the value climbs

**Task 2 — Image toggle & theme**
- Toggle Image fades out, swaps between a day city and a night city, and fades
  back in (`AnimationController` + `CurvedAnimation` + `FadeTransition`)
- Taps are ignored while the transition is mid-flight
- Light/dark mode toggle in the app bar

**Graduate task — Persistence**
- Counter value and current image are saved to `SharedPreferences` on every
  change and restored on launch
- Reset button, separate from the other controls
- Reset requires confirmation via a non-dismissible dialog
  (`barrierDismissible: false`) before it clears everything

## Script structure

```
lib/main.dart          the entire app
test/widget_test.dart  smoke test: app launches, Increment updates the counter
assets/image1.png      day city (default image)
assets/image2.png      night city
```

## Running it

```
flutter pub get
flutter run, for a device/emulator
```

## To build the release APK

```
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Technology used

Flutter · Dart · `shared_preferences`