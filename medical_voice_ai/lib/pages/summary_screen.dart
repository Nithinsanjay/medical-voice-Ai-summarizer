import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ai/tts_service.dart';
import '../ai/pdf_service.dart';
import '../data/models/consultation.dart';
import '../state/consultation_viewmodel.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({
    super.key,
    required this.transcript,
    required this.rawSummary,
    this.patientName = 'Patient',
  });

  final String transcript;
  final String rawSummary;
  final String patientName;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isSpeaking = false;
  bool _isExporting = false;
  bool _isSaving = false;
  bool _isSaved = false;

  // Parsed data
  late String _summaryText;
  late List<String> _medicines;
  late String _instructions;
  late String _followUp;

  @override
  void initState() {
    super.initState();
    _parseSummary(widget.rawSummary);
  }

  void _parseSummary(String raw) {
    _summaryText = _extract(raw, 'SUMMARY') ?? raw;
    _medicines = _extractList(raw, 'MEDICINES');
    _instructions = _extract(raw, 'INSTRUCTIONS') ?? '';
    _followUp = _extract(raw, 'FOLLOW UP') ?? 'Follow up with your doctor.';
  }

  String? _extract(String raw, String key) {
    final pattern = RegExp(
      r'(?:^|\n)' + key + r':\s*(.+?)(?=\n[A-Z ]+:|$)',
      dotAll: true,
      caseSensitive: false,
    );
    final match = pattern.firstMatch(raw);
    return match?.group(1)?.trim();
  }

  List<String> _extractList(String raw, String key) {
    final section = _extract(raw, key) ?? '';
    return section
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'^[-•*]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      await TtsService.instance.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final text =
          'Summary: $_summaryText. Medicines: ${_medicines.join('. ')}. Instructions: $_instructions. Follow up: $_followUp';
      await TtsService.instance.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await PdfService.instance.exportPrescriptionPdf(
        consultationId: id,
        patientName: widget.patientName,
        summary: _summaryText,
        medicines: _medicines,
        followUp: _followUp,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _saveConsultation() async {
    if (_isSaving || _isSaved) return;

    setState(() => _isSaving = true);
    final consultation = Consultation(
      id: generateId(),
      patientName: widget.patientName,
      dateTime: DateTime.now(),
      chiefComplaint: _summaryText.length > 60
          ? '${_summaryText.substring(0, 60)}...'
          : _summaryText,
      transcript: widget.transcript,
      summary: _summaryText,
      medicines: _medicines,
      followUp: _followUp,
    );

    if (!mounted) return;
    try {
      await context.read<ConsultationViewModel>().addConsultation(consultation);
      if (!mounted) return;
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation saved to history ✓'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prescription Summary'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: (_isSaved || _isSaving) ? null : _saveConsultation,
            tooltip: 'Save to History',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary card
          _SectionCard(
            icon: Icons.medical_information_outlined,
            title: 'Clinical Summary',
            color: Colors.teal.shade700,
            child: Text(
              _summaryText,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),

          // Medicines
          _SectionCard(
            icon: Icons.medication_liquid_outlined,
            title: 'Prescribed Medicines',
            color: Colors.indigo,
            child: _medicines.isEmpty
                ? const Text('No medicines prescribed.')
                : Column(
                    children: _medicines
                        .map((med) => _MedicineRow(medicine: med))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),

          // Instructions
          if (_instructions.isNotEmpty)
            _SectionCard(
              icon: Icons.checklist_rtl,
              title: 'Patient Instructions',
              color: Colors.deepOrange,
              child: Text(
                _instructions,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
          if (_instructions.isNotEmpty) const SizedBox(height: 16),

          // Follow up
          _SectionCard(
            icon: Icons.calendar_month_outlined,
            title: 'Follow Up',
            color: Colors.green.shade700,
            child: Text(
              _followUp,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),

          // Action buttons
          ElevatedButton.icon(
            onPressed: _toggleTts,
            icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.play_circle),
            label: Text(_isSpeaking ? 'Stop Reading' : 'Read Aloud'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportPdf,
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          if (!_isSaved)
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveConsultation,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: Text(_isSaving ? 'Saving...' : 'Save to History'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({required this.medicine});
  final String medicine;

  @override
  Widget build(BuildContext context) {
    // Split on first colon for name vs dosage
    final parts = medicine.split(':');
    final name = parts.first.trim();
    final details = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (details.isNotEmpty)
                  Text(details,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
