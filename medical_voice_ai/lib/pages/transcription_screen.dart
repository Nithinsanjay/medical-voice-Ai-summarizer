import 'dart:io';
import 'package:flutter/material.dart';
import '../ai/local_stt_service.dart';
import '../ai/qwen_service.dart';
import '../utils/constants.dart';
import 'summary_screen.dart';
import 'models_screen.dart';

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({
    super.key,
    required this.recordingPath,
    this.initialTranscript = '',
  });

  final String recordingPath;
  final String initialTranscript;

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  String _transcript = '';
  bool _isTranscribing = true;
  bool _isSummarizing = false;
  bool _editMode = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
    if (widget.initialTranscript.isNotEmpty) {
      _transcript = widget.initialTranscript;
      _editController.text = _transcript;
      _isTranscribing = false;
    } else {
      _transcribe();
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _transcribe() async {
    setState(() => _isTranscribing = true);
    try {
      final recordingFile = File(widget.recordingPath);
      if (widget.recordingPath.isEmpty || !await recordingFile.exists()) {
        throw Exception('Recording file was not found.');
      }
      final result = await LocalSttService.instance.transcribe(recordingFile);
      if (!mounted) return;
      setState(() {
        _transcript = result;
        _editController.text = result;
        _isTranscribing = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('not found')) {
        final path = await LocalSttService.instance.getWhisperModelPath();
        msg += '\n\nSearched path:\n$path';
      }

      setState(() {
        _errorMessage = msg;
        _isTranscribing = false;
      });
    }
  }

  String? _errorMessage;

  Future<void> _generateSummary() async {
    final text = _editMode ? _editController.text : _transcript;
    if (text.trim().isEmpty) return;

    setState(() => _isSummarizing = true);
    try {
      final summary = await QwenService.instance.summarize(text);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SummaryScreen(
          transcript: text,
          rawSummary: summary,
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Summary generation failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSummarizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transcription'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isTranscribing)
            IconButton(
              icon: Icon(_editMode ? Icons.done : Icons.edit_note),
              onPressed: () => setState(() => _editMode = !_editMode),
              tooltip: _editMode ? 'Done editing' : 'Edit transcript',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _isTranscribing
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isTranscribing
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  if (_isTranscribing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _isTranscribing
                        ? 'Transcribing audio with Whisper...'
                        : widget.initialTranscript.isNotEmpty
                            ? 'Transcription complete (System STT)'
                            : _editMode
                                ? 'Edit mode — tap Done when finished'
                                : 'Transcription complete (Whisper)',
                    style: TextStyle(
                      color: _isTranscribing
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transcript box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: _isTranscribing
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Processing audio...\nThis may take a moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ModelsScreen()),
                                  ),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Go to Downloads'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                ),
                              ],
                            ),
                          )
                        : _editMode
                            ? TextField(
                            controller: _editController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Edit the transcript here...',
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Text(
                              _transcript,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.7,
                              ),
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 20),

            // Generate Summary button
            ElevatedButton.icon(
              onPressed:
                  (_isTranscribing || _isSummarizing) ? null : _generateSummary,
              icon: _isSummarizing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.summarize_outlined),
              label: Text(_isSummarizing
                  ? 'Generating Summary...'
                  : 'Generate AI Summary'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
