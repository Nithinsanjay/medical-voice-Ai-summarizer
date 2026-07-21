# Implementation Plan - Fixing Model Download & Dynamic UI

The goal is to fix the Qwen model download issue and replace the static "Models" UI with a dynamic one that accurately reflects the download status.

## User Review Required

> [!IMPORTANT]
> **State Management Fix**: I found that the app was creating multiple "Model Downloader" instances. I will fix this so that the download progress remains consistent across all screens.
>
> **Dynamic Models Tab**: I will update the "Models" tab (the third icon on the bottom nav) to show the actual Whisper and Qwen models instead of the static Gemma/Phi-3 placeholders.

## Proposed Changes

### 1. Robust Download Logic

#### [MODIFY] [model_download_service.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/ai/model_download_service.dart)
- Add more detailed logging to the download process.
- Use `FileDownloader().download(task)` instead of `enqueue` for the primary foreground action, which is often more reliable for immediate UI feedback.
- Ensure the task is properly configured for the app's internal storage.

#### [MODIFY] [model_download_viewmodel.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/state/model_download_viewmodel.dart)
- Fix the logic that checks for existing models to ensure it doesn't return false positives.

### 2. UI Alignment

#### [MODIFY] [models_screen.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/pages/models_screen.dart)
- Remove the hardcoded static UI.
- Use `Consumer<ModelDownloadViewModel>` to show the actual Whisper and Qwen models and their download status.
- Add "Manage" and "Delete" options for installed models.

#### [MODIFY] [home_screen.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/pages/home_screen.dart)
- Remove redundant `ChangeNotifierProvider` creation when navigating to the Download screen. It will now correctly use the global provider from `main.dart`.

### 3. App Initialization

#### [MODIFY] [main.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/main.dart)
- Add basic configuration for `background_downloader` to ensure it's ready on app start.

## Verification Plan

### Manual Verification
1. **Consistency Test**:
   - Start a download on the **Home** screen.
   - Switch to the **Models** tab and verify the progress bar is in the exact same spot.
2. **Download Restart**:
   - If a download fails, click "Download" again and verify it resumes or restarts correctly without a "Cancellation" error.
3. **Dynamic Models**:
   - Verify that the **Models** tab now shows "Whisper" and "Qwen 3" instead of "Phi-3".
