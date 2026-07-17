# SerialBench

SerialBench - a serial COM toolkit for monitoring, plotting, and streaming data over USB serial on Android.

## About

SerialBench is an Android app for working with serial (UART) devices over USB OTG - think of it as an Arduino IDE Serial Monitor and Serial Plotter, but on your phone, with more planned along the way.

## Features

- **Serial Monitor** - view raw incoming serial data in real time.
- **Serial Plotter** - plot numeric serial data live on a scrolling graph.
- **Audio over Serial** *(planned)* - stream audio in/out over a serial link, built for low-bandwidth microcontroller-to-microcontroller audio relay projects.
- **More serial tools** *(planned)* - additional utilities as the app grows.

## Build

Built and Tested on Dart SDK 3.12.2 and Flutter 3.44.6

Set the following environment variables (signing credentials):
- `KEYSTORE_PATH`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `KEYSTORE_PASSWORD`

Then run:
> make build

OR

> flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/debug-info

Output: `build/app/outputs/flutter-apk/app-release.apk` (arm64 only)

___

**Alternatively:**

-Build an Android APK file
> flutter build apk

    Output: `build/app/outputs/flutter-apk/app-release.apk` (multi-arch)

-Build an Android App File Bundle
> flutter build appbundle

    Output: `build/app/outputs/bundle/release/app-release.aab` (multi-arch)

## License

GNU GPL v3 license
