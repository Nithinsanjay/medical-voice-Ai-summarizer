# Implementation Plan - Refine AGP 9.0.1 Integration

The goal is to successfully use AGP 9.0.1 and Kotlin 2.3.20 by fixing the `AndroidLocationsBuildService` initialization error while keeping the user's requested "bypass" logic.

## User Review Required

> [!IMPORTANT]
> **Absolute Paths**: I will restore the logic that forces an absolute canonical path for the Flutter SDK in `settings.gradle.kts`. This is a known requirement for AGP 9.x to correctly initialize its internal services.

> [!NOTE]
> I will re-enable JDK desugaring to ensure maximum compatibility with Flutter plugins, as this was present in your working state before the upgrade.

## Proposed Changes

### Build Initialization

#### [MODIFY] [settings.gradle.kts](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/android/settings.gradle.kts)
- Restore canonical path resolution:
  ```kotlin
  includeBuild(file("$flutterSdkPath/packages/flutter_tools/gradle").toPath().toRealPath().toAbsolutePath().toString())
  ```

#### [MODIFY] [gradle.properties](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/android/gradle.properties)
- Add `android.sdk.channel=0` to stabilize SDK lookup.

### App Configuration

#### [MODIFY] [app/build.gradle.kts](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/android/app/build.gradle.kts)
- Re-add `isCoreLibraryDesugaringEnabled = true` and the corresponding dependency.
- Keep JVM 17 and AGP 9 targets.

## Verification Plan

### Automated Tests
- Run `gradlew clean` to verify the service initialization error is resolved.
- Run `gradlew :app:assembleDebug` (dry run) if possible.

### Manual Verification
- Confirm Gradle syncs successfully in the IDE.
