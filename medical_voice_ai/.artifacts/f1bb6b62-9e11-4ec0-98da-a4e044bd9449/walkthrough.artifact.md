# Walkthrough - Bleeding-Edge Gradle Upgrade (AGP 9.0.1)

I have successfully updated your project to use the latest bleeding-edge Android build tools as requested.

## Applied Versions
- **Android Gradle Plugin (AGP)**: `9.0.1`
- **Kotlin**: `2.3.20`
- **Gradle Wrapper**: `9.3.1` (Upgraded from 8.x to support AGP 9)

## Changes Made

### 1. Build Infrastructure Upgrade
- Updated `android/gradle/wrapper/gradle-wrapper.properties` to **Gradle 9.3.1**.
- Updated `android/settings.gradle.kts` to apply **AGP 9.0.1** and **Kotlin 2.3.20**.
- Refined `settings.gradle.kts` to use absolute canonical paths for the Flutter SDK, which is required for AGP 9's location services.

### 2. Compatibility & Bypass Flags
Added the following to `android/gradle.properties`:
- `android.newDsl=false`: Maintains compatibility with your current script structure.
- `android.enableLegacyVariantApi=true`: Essential for many Flutter plugins to work with AGP 9.
- `android.builtInKotlin=false`: Prevents conflicts with the Flutter-managed Kotlin setup.

### 3. Script Cleanup
- Updated `android/app/build.gradle.kts` to use JVM 17 targets and manually set `compileSdk` to 36 to satisfy AGP 9 requirements.
- Cleaned up the `android/build.gradle.kts` to a minimal stable state.

## Critical Environment Fix Required

> [!CAUTION]
> **Build Error: `AndroidLocationsException`**
> During verification, I identified a system-level conflict that prevents AGP 9.0.1 from starting on your machine.
>
> **The Issue**: You have both `ANDROID_PREFS_ROOT` and `ANDROID_USER_HOME` set in your Windows Environment Variables. AGP 9 strictly forbids having multiple ways to define the Android preferences folder.
>
> **The Fix**:
> 1. Open **Environment Variables** on your Windows machine.
> 2. **Delete** the variable named `ANDROID_PREFS_ROOT`.
> 3. Ensure `ANDROID_USER_HOME` is the only one remaining (set to `C:\Users\Nithin Sanjay\.android`).
> 4. Restart Android Studio/Terminal and run your build again.

Once you fix this environment conflict, the project should build successfully with the new versions.
