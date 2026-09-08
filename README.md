# Chronowarp

Flutter Android app for movie tracking and watch parties. Project scaffolding
reconstructed with Flutter 3.47.2 and Dart 3.13.2.

## Build

```sh
flutter pub get
flutter test
flutter build apk --debug --target-platform android-arm64
```

## Firebase configuration

The original dependency files and google-services.json were restored from the
repository. lib/firebase_options.dart contains the Android client options from
that JSON, and main.dart initializes Firebase explicitly with those options.
If the Firebase configuration changes, update both files together.

Debug builds use com.example.chronowarp.dev and the label Chronowarp Dev to
preserve the original app signed on another computer. They use the existing
Firebase backend. Package/signature-sensitive features such as Google sign-in
or Play Integrity would require a separately registered debug Firebase client.
The icon is a generated default. Release signing is not configured.

## Wireless device

Keep the phone and computer on the same Wi-Fi. Open Android Developer options,
Wireless debugging, then Pair device with pairing code.

```sh
adb pair PHONE_IP:PAIRING_PORT
adb devices -l
flutter devices
flutter run -d DEVICE_ID
```

ADB prompts for the pairing code. If discovery does not connect automatically,
use adb connect with the IP and debugging port from the main Wireless debugging
screen. Pairing and debugging ports differ and can change.

## Source control

Commit lib/, assets/, android/, pubspec.yaml, pubspec.lock, and .metadata.
Generated build/cache folders and local SDK paths are ignored. Do not commit
service-account credentials or signing keys.
