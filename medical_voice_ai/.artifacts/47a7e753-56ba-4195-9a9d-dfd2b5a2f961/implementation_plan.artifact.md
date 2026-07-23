# Fix AI Engine Error & Restore Build Paths

I will resolve the `Bad state: No inference engine can handle this model` error by switching to the more robust **MediaPipe** engine and fix the `APK not found` error by restoring standard Flutter build paths.

## User Review Required

> [!IMPORTANT]
> **Switching AI Engine to MediaPipe**
> I am replacing `flutter_gemma_litertlm` with `flutter_gemma_mediapipe`. MediaPipe is the "bulletproof" engine for `.task` and `.bin` models on mobile, which should permanently resolve the initialization error you are seeing.
>
> **Restoring Standard Build Paths**
> I am removing the custom build directory logic in `android/build.gradle.kts`. This will ensure `flutter build` can find the generated APK in its default location, preventing the "couldn't find it" error.

## Proposed Changes

### 1. Dependencies

#### [MODIFY] [pubspec.yaml](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/pubspec.yaml)
- Remove `flutter_gemma_litertlm: ^1.1.0`.
- Add `flutter_gemma_mediapipe: ^1.1.0`.

### 2. Initialization

#### [MODIFY] [main.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/main.dart)
- Replace `LiteRtLmEngine()` with `MediaPipeEngine()`.
- Update imports accordingly.

### 3. AI Service Logic

#### [MODIFY] [qwen_service.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/ai/qwen_service.dart)
- Ensure `ModelFileType.task` is used (compatible with MediaPipe).
- Update download logic if necessary (MediaPipe handles `.task` and `.bin` well).

### 4. Build System

#### [MODIFY] [android/build.gradle.kts](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/android/build.gradle.kts)
- Remove the `newBuildDir` and related redirection logic to restore standard Flutter build directory behavior.

## Verification Plan

### Automated Tests
- Run `flutter clean`.
- Run `flutter pub get`.
- Run `flutter build apk --debug`.

### Manual Verification
- Deploy the app and navigate to the **Models** screen.
- Verify that the **Qwen 3 0.6B LLM** initializes successfully without the "Bad state" error.
