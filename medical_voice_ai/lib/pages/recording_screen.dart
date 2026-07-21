import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../ai/speech_to_text_service.dart';
import '../state/settings_viewmodel.dart';
import '../utils/constants.dart';
import 'transcription_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _recordingPath;
  String? _errorMessage;
  String _liveTranscript = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final settingsVm = context.read<SettingsViewModel>();
    if (settingsVm.preferredSttEngine == SttEngine.system) {
      await SpeechToTextService.instance.initialize();
    }
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
        setState(() => _errorMessage = 'Microphone permission is required.');
      }
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      setState(() => _liveTranscript = '');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      final settingsVm = context.read<SettingsViewModel>();
      if (settingsVm.preferredSttEngine == SttEngine.system) {
        await SpeechToTextService.instance.startListening(
          onResult: (text) {
            if (mounted) {
              setState(() => _liveTranscript = text);
            }
          },
        );
      }

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordingPath = path;
        _errorMessage = null;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _isRecording && !_isPaused) {
          setState(() => _duration += const Duration(seconds: 1));
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Recording could not be started: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    }
  }

  Future<void> _togglePause() async {
    if (!_isRecording) return;
    if (_isPaused) {
      await _recorder.resume();
      final settingsVm = context.read<SettingsViewModel>();
      if (settingsVm.preferredSttEngine == SttEngine.system) {
        await SpeechToTextService.instance.startListening(
          onResult: (text) {
            if (mounted) {
              setState(() => _liveTranscript = text);
            }
          },
        );
      }
    } else {
      await _recorder.pause();
      await SpeechToTextService.instance.stopListening();
    }
    if (!mounted) return;
    setState(() => _isPaused = !_isPaused);
  }

  Future<void> _stopAndTranscribe() async {
    if (!_isRecording && _recordingPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording is available to transcribe.')),
      );
      return;
    }

    _timer?.cancel();
    final path = await _recorder.stop();
    await SpeechToTextService.instance.stopListening();

    if (!mounted) return;
    setState(() => _isRecording = false);

    final recordingPath = path ?? _recordingPath;
    if (recordingPath == null || recordingPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording file was not created.')),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TranscriptionScreen(
          recordingPath: recordingPath,
          initialTranscript: _liveTranscript,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Consultation'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _errorMessage != null
                    ? Colors.grey.shade100
                    : _isPaused
                        ? Colors.orange.shade50
                        : Colors.red.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _errorMessage != null
                      ? Colors.grey.shade300
                      : _isPaused
                          ? Colors.orange
                          : Colors.red.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _errorMessage != null
                          ? Colors.grey
                          : _isPaused
                              ? Colors.orange
                              : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _errorMessage != null
                        ? 'Recording unavailable'
                        : _isPaused
                            ? 'Paused'
                            : 'Recording...',
                    style: TextStyle(
                      color: _errorMessage != null
                          ? Colors.grey.shade700
                          : _isPaused
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Pulsing mic button
            ScaleTransition(
              scale: _isPaused
                  ? const AlwaysStoppedAnimation(1.0)
                  : _pulseAnimation,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isPaused
                        ? [Colors.grey.shade300, Colors.grey.shade400]
                        : [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7)
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isPaused ? Colors.grey : AppColors.primary)
                          .withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _isPaused ? Icons.pause_circle_outline : Icons.mic,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Duration
            Text(
              _formatDuration(_duration),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            if (context.read<SettingsViewModel>().preferredSttEngine == SttEngine.system && _isRecording && !_isPaused)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Listening...',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Doctor–Patient Conversation',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_liveTranscript.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _liveTranscript,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
            const SizedBox(height: 32),

            // Speaker chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChip('🩺 Doctor', !_isPaused),
                const SizedBox(width: 12),
                _buildChip('🧑 Patient', !_isPaused),
              ],
            ),
            const Spacer(),

            // Controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRecording ? _togglePause : null,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'Resume' : 'Pause'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRecording ? _stopAndTranscribe : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop & Transcribe'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.primary.withValues(alpha: 0.4) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.primary : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
