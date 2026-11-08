# Changelog

All notable changes to **AskOptSam** are documented in this file.

## [2.4.5] - 2026-11-08

### Fixed
- **Android IPv6 Blackhole Fix (`GeminiHttp`)**: Fixed `dart:io` hanging for 20+ seconds on mobile/ISP networks with broken IPv6 (`AAAA`) routes to `generativelanguage.googleapis.com` by resolving IPv4 (`A`) addresses first (`<40ms` TLS connect).
- **Gemini Neural Voice Playback (`GeminiVoice`)**: Writes synthesized 24 kHz WAV clips to temporary storage and plays via `DeviceFileSource` on Android so `Charon`, `Kore`, `Puck`, `Aoede`, `Fenrir`, `Zephyr`, `Leda`, and `Orus` play reliably without falling back to the phone TTS engine.

### Verified
- Tested live on Android Emulator (`emulator-5554`):
  - **Voice Test (`Sikiliza sauti hii`)**: Passed (`HTTP 200` in `7.4s`, *"Sauti ya msaidizi iko tayari: Charon."*).
  - **Camera Vision (`Elezea mazingira` / `Soma`)**: Passed (`gemini-2.5-flash` `HTTP 200` in `2.8s` + `gemini-2.5-flash-preview-tts` narration).
- Built universal Android APK supporting `arm64-v8a`, `armeabi-v7a`, and `x86_64`.

---

## [2.4.4] - 2026-11-08

### Changed
- Restored original `eye-0.3.3` AI models (`gemini-2.5-flash` with `thinkingBudget: 0` for vision and `gemini-2.5-flash-preview-tts` for neural voice synthesis).
- Disabled R8 minification/resource shrinking in release builds to match original `eye-0.3.3.apk` plugin compatibility.

---

## [2.4.3] - 2026-11-07

### Changed
- Ported complete **Eye 0.3.3** module (`HomeScreen`, `ReadScreen`, `AskScreen`, `DescribeScreen`, `SettingsScreen`, `Poppins` font family, and `eye-mark.png` logo) into `lib/eye/`.
- Restored original single big-eye blinking vector `Mascot`.

---

## [2.4.2] - 2026-11-07

### Added
- Added clickable **Sera ya Faragha na Masharti / Privacy Policy & Terms** links on both `SignInScreen` and `SignUpScreen` before login.
- Added subtle non-blocking update pill alongside in-app update notifications.
