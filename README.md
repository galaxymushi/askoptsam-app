<p align="center">
  <img src="assets/branding/logo.png" width="160" alt="AskOptSam logo" />
</p>

<h1 align="center">AskOptSam</h1>

<p align="center">
  <b>Seeing Is Believing.</b><br />
  A Kiswahili-first AI optometry & vision assistant for Android — chat, daily eye facts,
  and native vision assistant <b>Eye · Msaidizi wa Maono</b> with Smart Glasses (Bluetooth BLE) integration.
</p>

<p align="center">
  <a href="https://github.com/galaxymushi/askoptsam-eye/releases/latest"><img src="https://img.shields.io/github/v/release/galaxymushi/askoptsam-eye?label=release&color=2E6BFF" alt="Latest release" /></a>
  <a href="https://github.com/galaxymushi/askoptsam-eye/releases/latest/download/app-release.apk"><img src="https://img.shields.io/badge/download-APK-2E6BFF" alt="Download APK" /></a>
  <img src="https://img.shields.io/badge/platform-Android%206.0%2B-3DDC84" alt="Android" />
  <img src="https://img.shields.io/badge/language-Flutter%20%7C%20Dart-02569B" alt="Flutter" />
  <img src="https://img.shields.io/badge/lugha-Kiswahili%20%7C%20English-111827" alt="Languages" />
  <img src="https://img.shields.io/badge/tests-27%20passing-brightgreen" alt="Tests" />
</p>

<p align="center">
  <a href="#download">Download</a> ·
  <a href="#features">Features</a> ·
  <a href="#eye--msaidizi-wa-maono">Eye Msaidizi</a> ·
  <a href="#smart-glasses-integration">Smart Glasses</a> ·
  <a href="#the-mascot">Interactive Mascot</a> ·
  <a href="#build-it-yourself">Build</a> ·
  <a href="#release-process">Releases</a> ·
  <a href="#kiswahili">Kiswahili</a>
</p>

---

AskOptSam is a Flutter Android application built for Optsam Eye Care. It answers
everyday eye-health questions in **Kiswahili or English**, teaches with
**28 daily eye facts** (each with a real, openly-licensed photograph), provides
an **autonomous daily AI briefing**, and features **Eye · Msaidizi wa Maono** —
a live camera and audio vision companion ready for **Smart Glasses (Bluetooth BLE)**.

> **Not a medical device.** AskOptSam gives general eye-health information
> only. It does not diagnose, prescribe or replace an optometrist. For an
> emergency (chemical splash, sudden vision loss, penetrating injury) go to a
> clinic immediately.

## Download

| | |
| --- | --- |
| **Latest APK** | [**galaxymushi/askoptsam-app/releases/latest**](https://github.com/galaxymushi/askoptsam-app/releases/latest/download/app-release.apk) |
| **All releases** | [Releases page](https://github.com/galaxymushi/askoptsam-app/releases) |
| **Current version** | **2.4.0** (`versionCode 13`) — APK ≈ 38 MB |
| **Support** | optsamtz@gmail.com |

Install the APK, allow "install from unknown sources" if Android asks, and
open the app. The app checks GitHub Releases on launch: if a newer version
exists it shows a **blocking update dialog** — download the newest APK to
continue.

---

## Features

- **Unified Mother Application** — AskOptSam serves as the central hub uniting AI eye consultation, educational libraries, and the Eye vision assistant under one cohesive design system.
- **Chat with AskOptSam** — an eye-health assistant that replies in the language you write in (Kiswahili / English), with citation markers stripped from replies so answers read cleanly.
- **Eye Shortcut Banner** — integrated directly into the chat header, allowing instant 1-tap transition into visual assistance mode.
- **Interactive Mascot** — fully vector-rendered OptSam mascot without dusty artifacts:
  - Real-time **GazeScope tracking** (follows finger and cursor across the screen)
  - **Tap interaction**: mascot hops, blinks, waves, and offers greeting feedback
  - Multi-state animations: floating bob, swaying, and thinking state.
- **Maktaba (Library)** — 28 eye facts on a 28-day cycle, each with a real Wikimedia photograph, photographer credit and licence.
- **Jambo jipya la leo (Daily briefing)** — seeded briefings cached daily and refreshed autonomously.
- **Real notifications** — status-bar notifications via `flutter_local_notifications` (tips, replies, welcome, new releases) with an in-app notification centre and unread badge.
- **Forced updates** — a modal gate with `barrierDismissible: false` that keeps the app usable if GitHub is unreachable (never locks you out offline).
- **Accounts, optional** — sign in with email or use the app locally; chats are stored on-device and synced only when a cloud account is used.
- **Bilingual + dark mode** — full Kiswahili / English UI and an authentic OLED dark theme, both persisted.

---

## Eye · Msaidizi wa Maono

Integrated directly into AskOptSam as the 2nd tab and accessible via the chat quick-banner, **Eye** is designed for the visually impaired and everyday visual assistance:

```
┌──────────────────────────────────────────────┐
│  [ (◎) Eye Logo ]  Eye                       │
│                    Tazama dunia kwa sauti    │
├──────────────────────────────────────────────┤
│  [ Miwani Janja (BLE) ]        [ ○ Switch ]  │
├──────────────────────────────────────────────┤
│  ┌────────────────────────────────────────┐  │
│  │ 📘 Soma                                │  │
│  │    Sikiliza maandishi yaliyo mbele yako│  │
│  └────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────┐  │
│  │ ❓ Uliza                                │  │
│  │    Uliza swali kuhusu unachokiona      │  │
│  └────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────┐  │
│  │ 👁️ Elezea                               │  │
│  │    Sikia mazingira yako yakielezwa     │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  [ Sauti imewashwa · Gusa kitufe kuanza ]   │
│  [ ⏹️ Acha kusema ]                          │
└──────────────────────────────────────────────┘
```

### Core Vision Modes:
1. **Soma (Read)**:
   - High-contrast viewfinder with animated dashed scanning reticle.
   - Captures and reads aloud clinic signs, medicine labels, menus, prescription bottles, and documents.
2. **Uliza (Ask)**:
   - Point the camera or Smart Glasses at any object and ask questions verbally.
3. **Elezea (Describe)**:
   - Comprehensive scene understanding narrated in Kiswahili or English to guide spatial orientation.

---

## Smart Glasses Integration

AskOptSam v2.4.0 is engineered with hardware abstraction ready for wearable computing:

- **Bluetooth Low Energy (BLE) Bridge**: Connects to smart eyewear peripherals (e.g. Ray-Ban Meta, Monocle, custom ESP32/Nordic BLE smart frames) to stream camera snapshots and receive push-to-talk triggers.
- **Offline TTS & Audio Synthesis**: Fallback audio synthesis pipeline ensures speech cues function even when cellular connectivity drops.

---

## The Mascot

OptSam's interactive cyborg mascot is drawn via `CustomPainter` with 100% vector mathematics:
- **Zero Dusty Lines**: Replaced fuzzy bitmap edges and unclosed arc strokes with smooth cubic Bézier curves and rounded cap paths.
- **Interactive Tap Hop**: Tapping the mascot triggers an energetic jump, visor wink, and tactile toast message.
- **Smooth Headset & Eye Visor**: Deep navy and glowing cyan visor displaying expressive pupil movement that tracks user touch via `GazeScope`.

---

## Tech Stack

| Layer | Choice |
| --- | --- |
| Framework | Flutter (Dart SDK ^3.13.7) — Android only |
| Vision & Speech | Eye · Msaidizi wa Maono (Camera viewfinder, OCR & TTS pipeline) |
| Hardware Link | Bluetooth BLE Peripheral Bridge |
| AI | Hosted AskOptsam assistant (`askoptsam` protocol) or OpenAI-compatible backend |
| Backend | Firebase Auth + Cloud Firestore (optional; app works fully offline without them) |
| Notifications | `flutter_local_notifications` (real status-bar notifications) |
| Local storage | `shared_preferences` + on-device chat store |
| UI | Custom design system, Inter font, custom vector interactive mascot |
| Releases | Signed APK published to GitHub Releases |

### Project Layout

```
askoptsam/
├── lib/
│   ├── main.dart                  # bootstrap, UpdateGate, GazeScope
│   ├── config.dart                # build-time --dart-define values
│   ├── l10n.dart                  # Kiswahili + English translations (single source)
│   ├── theme.dart, app_state.dart, models.dart
│   ├── screens/
│   │   ├── app_shell.dart         # 4-tab navigation shell (Chat, Eye, Library, Settings)
│   │   ├── chat_screen.dart       # AskOptSam AI conversation + Eye quick launcher
│   │   ├── eye_assistant_screen.dart # Eye · Msaidizi wa Maono (Soma, Uliza, Elezea)
│   │   ├── library_screen.dart    # 28 rotating eye facts
│   │   └── settings_screen.dart   # persistent settings & theme toggles
│   ├── services/                  # ai, auth, chat store, notifications, updates
│   ├── content/                   # 28 eye facts + photos + legal text
│   └── widgets/                   # UI kit, interactive mascot, dashed viewfinder
└── test/                          # 27 automated tests (100% green)
    ├── citations_test.dart
    ├── eye_assistant_test.dart    # Eye dashboard, camera mode, mascot tap tests
    ├── features_test.dart
    ├── update_gate_test.dart
    └── widget_test.dart
```

---

## Build it yourself

```powershell
# Windows: point Gradle at a JDK 17
$env:JAVA_HOME = "C:\path\to\jdk-17"

flutter pub get
flutter build apk --release --obfuscate --split-debug-info=build/symbols
# → build\app\outputs\flutter-apk\app-release.apk
```

### Pre-release Verification

```powershell
dart analyze lib test    # Result: "No issues found!"
flutter test             # Result: "All tests passed!" (27 tests)
```

---

## Release Process

1. Bump `version:` in `pubspec.yaml` (`x.y.z+N`) and `_fallbackInstalledVersion` in `lib/services/update_service.dart`.
2. Run `dart analyze lib test` and `flutter test`.
3. Commit and tag release in git (`git tag -a v2.4.0 -m "Release v2.4.0"`).
4. Build the signed APK.
5. Create GitHub Release with release notes and attach APK.

### Version History

| Version | Highlights |
| --- | --- |
| **2.4.0** | **Unified Release**: AskOptSam mother app integrates **Eye · Msaidizi wa Maono** (Soma, Uliza, Elezea); Smart Glasses BLE readiness; redesigned smooth interactive Mascot with hop & wink; 27 automated tests. |
| 2.3.6 | APK shrunk 59 MB → 38 MB (arm-only ABIs); on-topic eye-question suggestion chips |
| 2.3.5 | Payments removed entirely; founders' names fixed; chat update bar moved to the bottom; tabs reordered |
| 2.3.4 | Download button retires per version after fetching |
| 2.3.3 | Blocking force-update gate |
| 2.3.2 | 8 more eye facts (28 total) with licensed photos |
| 2.3.1 | Citation markers stripped from replies |
| 2.3.0 | In-app update notification + one-tap download |
| 2.2.0 | Real photographs on every library fact |
| 2.1.0 | First signed APK release |

---

## Contributors

<p>
  <b>J.M. SAMWEL</b> — Founder · <b>J.M. EMANUELI</b> — Co-founder
</p>

Questions, bugs or feedback: **[optsamtz@gmail.com](mailto:optsamtz@gmail.com)**

---

## Kiswahili

AskOptSam ni programu kuu inayochanganya ushauri wa AI wa afya ya macho na **Eye — Msaidizi wa Maono**.

**Vipengele Vipya vya Toleo la 2.4.0:**
1. **Eye · Msaidizi wa Maono:**
   - **Soma:** Inasoma maandishi yoyote mbele yako (mabango, chupa za dawa, menyu).
   - **Uliza:** Uliza swali lolote kwa kutumia picha ya moja kwa moja.
   - **Elezea:** Maelezo ya kina ya sauti kuhusu mazingira unamoishi.
2. **Uunganishaji wa Miwani Janja (Smart Glasses):**
   - Tayari kuunganishwa na miwani ya kidijitali kupitia Bluetooth (BLE).
3. **Mascot Mpya na Mahiri:**
   - Mistari safi ya vector bila mikwaruzo wala vumbi.
   - Hufuata kidole cha mtumiaji (`GazeScope`), inaruka na kukonyeza jicho unapogusa (`Interactive Tap`).
4. **Vipimo 27 Vimekamilika:**
   - Vipimo vyote vya kiufundi vimefaulu kwa 100% (`flutter test`).
