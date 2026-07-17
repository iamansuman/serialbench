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

Built and Tested on:
- Fedora 44
- OpenJDK Temurin-21.0.5+11 (build 21.0.5+11-LTS)
- Dart SDK 3.12.2 and Flutter 3.44.6
- Tested on Android 14

Set the following environment variables (signing credentials):
- `KEYSTORE_PATH`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `KEYSTORE_PASSWORD`

Then run:
> make build

OR

> flutter build apk --release --split-per-abi --split-debug-info=build/debug-info

Output: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (ARM 32-bit)\
Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (ARM 64-bit)\
Output: `build/app/outputs/flutter-apk/app-x86_64-release.apk` (x86 64-bit)\

___

**Alternatively:**

- Build an Android APK file
> flutter build apk --release

    Output: `build/app/outputs/flutter-apk/app-release.apk` (multi-arch)

- Build an Android App File Bundle
> flutter build appbundle --release

    Output: `build/app/outputs/bundle/release/app-release.aab` (multi-arch)

## License

GNU GPL v3 license
