.PHONY: build clean

all: build

clean:
	flutter clean
	rm -f pubspec.lock
	rm -rf android/.gradle android/app/build

build:
	flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/debug-info