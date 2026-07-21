# Fix Qwen Model Initialization Failure

The "Generate Summary" feature is failing because the AI service attempts to retrieve an active model before one has been installed or activated. The `flutter_gemma` package throws a "Bad state: No active inference model set" exception instead of returning `null` when no model is active, which prevents the initialization flow from proceeding to the installation step.

## User Review Required

> [!IMPORTANT]
> This fix assumes that `FlutterGemma.getActiveModel()` is throwing an exception by design when no model is active. By catching this exception, we allow the service to proceed with `installModel()` if the model file exists locally.

## Proposed Changes

### AI Services

#### [MODIFY] [qwen_service.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/ai/qwen_service.dart)
- Wrap the initial `FlutterGemma.getActiveModel()` call in a `try-catch` block.
- If an exception occurs (indicating no active model), set `_model` to `null` and continue to the installation logic.

#### [MODIFY] [initialize.dart](file:///E:/medical-voice-Ai-summarizer/medical_voice_ai/lib/ai/initialize.dart)
- Apply the same `try-catch` wrapper to `GemmaService.initialize()` to prevent similar crashes if this service is ever used or initialized.

## Verification Plan

### Manual Verification
1. Open the app and go to the "Transcription" screen.
2. Click "Generate AI Summary".
3. Verify that the "Summary generation failed" error no longer appears and the summary is generated successfully (assuming the model is already downloaded).
4. If the model is not downloaded, verify that the error message correctly instructs the user to download the model from the Models screen.
