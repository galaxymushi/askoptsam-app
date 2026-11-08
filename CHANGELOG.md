# Changelog

All notable changes to **AskOptSam** are documented in this file.

## [2.4.7] - 2026-11-08

### Added
- **Cloud Firestore Chat History Synchronization (`FirestoreChatStore` + `LocalChatStore` Hybrid)**:
  - Provisioned **Cloud Firestore** in project `askoptsam-eye` with strict owner-scoped security rules (`firestore.rules`) so each user's saved optometry conversations (`users/{uid}/sessions/{sessionId}`) and profile (`users/{uid}`) sync automatically across devices while remaining accessible offline.
- **Comprehensive Legal & Data-Protection Policy (`LegalText` — Tanzania PDPA 2022 & International Standards)**:
  - Expanded bilingual (Kiswahili & English) **Privacy Policy & Terms of Service** (`Sera na Masharti`) with 10 privacy sections and 9 legal terms sections: strict data minimization, zero retention of Eye camera images/voice audio, strict no-sale/no-ad-tracking guarantee, right to instant erasure (`Delete all chats`), clinical non-diagnosis disclaimer, low-vision mobility safety disclaimer, limitation of liability, indemnification, and governing law of Tanzania.

---

## [2.4.6] - 2026-11-08

### Fixed
- **Ultra-Low-Latency Streaming Neural Voice (`GeminiVoice`)**:
  - Upgraded primary TTS model to `gemini-3.8-flash-tts` (`~2.8–3.2s` synthesis vs `5–15s` previously) with automatic fallback to `gemini-2.5-flash-preview-tts`.
  - Added sentence-level parallel prefetch (`GeminiVoice.splitSentences`): synthesizes and plays the **first sentence immediately** while remaining sentences download concurrently in the background, cutting initial wait time by 70%.
- **Eliminated Mid-Sentence Speech Cutoffs**:
  - Added strict `_activeRunId` cancellation token and isolated per-run `.wav` files (`eye_voice_${runId}_0.wav` / `eye_voice_${runId}_rest.wav`) so background navigation announcements (`homeSpeak`) can never interrupt or overwrite active `Soma` / `Elezea` / `Uliza` speech.
  - Concatenates all multi-part `inlineData` PCM audio buffers (`ttsExtractAllPcm`) and plays remaining sentences seamlessly to completion with `AudioContextAndroid(stayAwake: true)`.
  - Stopped active home speech immediately upon opening `ReadScreen`, `DescribeScreen`, `AskScreen`, or `SettingsScreen`, and prevented `DescribeScreen`'s auto-describe timer from interrupting ongoing speech.

### Added
- **Firebase Cloud Authentication (`askoptsam-eye`)**:
  - Connected live **Firebase Authentication** (Email/Password) under project `askoptsam-eye` for cloud user accounts, usernames (`displayName`), and email password resets, while keeping chat history fast and lightweight on the phone (`LocalChatStore`) with automatic offline account caching.
  - Added show/hide password eye toggle on all password fields (`SignInScreen`, `SignUpScreen`, `ForgotPasswordScreen`, `ProfileScreen`).
  - Added password change (`changePassword`) in `ProfileScreen`.

---

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
