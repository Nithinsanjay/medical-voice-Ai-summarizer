import 'package:flutter/material.dart';
import '../ai/pdf_service.dart';
import '../ai/tts_service.dart';
import '../data/models/consultation.dart';
import '../state/history_viewmodel.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'package:provider/provider.dart';

class ConsultationDetailScreen extends StatefulWidget {
  const ConsultationDetailScreen({super.key, required this.consultation});
  final Consultation consultation;

  @override
  State<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  bool _isSpeaking = false;
  bool _isExporting = false;
  bool _isEditing = false;
  int _selectedTab = 0;

  late TextEditingController _summaryController;
  late TextEditingController _medicinesController;
  late TextEditingController _followUpController;
  late TextEditingController _vitalsController;
  late TextEditingController _diagnosisController;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.consultation.summary);
    _medicinesController = TextEditingController(text: widget.consultation.medicines.join('\n'));
    _followUpController = TextEditingController(text: widget.consultation.followUp);
    _vitalsController = TextEditingController(text: widget.consultation.vitals);
    _diagnosisController = TextEditingController(text: widget.consultation.diagnosis);
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _medicinesController.dispose();
    _followUpController.dispose();
    _vitalsController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      await TtsService.instance.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final text =
          'Summary: ${_summaryController.text}. Medicines: ${_medicinesController.text.replaceAll('\n', '. ')}. Follow up: ${_followUpController.text}';
      await TtsService.instance.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final c = widget.consultation;
      await PdfService.instance.exportPrescriptionPdf(
        consultationId: c.id,
        patientName: c.patientName,
        summary: _summaryController.text,
        medicines: _medicinesController.text.split('\n').where((s) => s.isNotEmpty).toList(),
        followUp: _followUpController.text,
        diagnosis: _diagnosisController.text,
        vitals: _vitalsController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _deleteConsultation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Consultation'),
        content: const Text(
            'Are you sure you want to permanently delete this consultation record?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context
          .read<HistoryViewModel>()
          .deleteConsultation(widget.consultation.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.consultation;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(c.patientName),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Save changes to DB
                final updated = Consultation(
                  id: c.id,
                  patientName: c.patientName,
                  dateTime: c.dateTime,
                  chiefComplaint: _summaryController.text.length > 60 
                    ? '${_summaryController.text.substring(0, 60)}...' 
                    : _summaryController.text,
                  transcript: c.transcript,
                  summary: _summaryController.text,
                  medicines: _medicinesController.text.split('\n').where((s) => s.isNotEmpty).toList(),
                  followUp: _followUpController.text,
                  diagnosis: _diagnosisController.text,
                  vitals: _vitalsController.text,
                );
                context.read<HistoryViewModel>().updateConsultation(updated);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation updated')));
              }
              setState(() => _isEditing = !_isEditing);
            },
            tooltip: _isEditing ? 'Save Changes' : 'Edit Records',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteConsultation,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            color: AppColors.primary.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_outline,
                      color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.patientName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(formatDate(c.dateTime),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: Row(
              children: ['Summary', 'Medicines', 'Transcript'].map((label) {
                final idx =
                    ['Summary', 'Medicines', 'Transcript'].indexOf(label);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == idx
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == idx
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Tab content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildTabContent(c),
            ),
          ),

          // Bottom actions
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleTts,
                    icon: Icon(
                        _isSpeaking ? Icons.stop : Icons.play_arrow),
                    label: Text(_isSpeaking ? 'Stop' : 'Read Aloud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : _exportPdf,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Consultation c) {
    switch (_selectedTab) {
      case 0:
        return _SummaryTab(
          summaryController: _summaryController,
          followUpController: _followUpController,
          vitalsController: _vitalsController,
          diagnosisController: _diagnosisController,
          isEditing: _isEditing,
        );
      case 1:
        return _MedicinesTab(
          medicinesController: _medicinesController,
          isEditing: _isEditing,
        );
      case 2:
        return _TranscriptTab(transcript: c.transcript);
      default:
        return const SizedBox();
    }
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({
    required this.summaryController,
    required this.followUpController,
    required this.vitalsController,
    required this.diagnosisController,
    required this.isEditing,
  });
  final TextEditingController summaryController;
  final TextEditingController followUpController;
  final TextEditingController vitalsController;
  final TextEditingController diagnosisController;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Vitals',
                  child: isEditing
                      ? TextFormField(controller: vitalsController, maxLines: null, decoration: const InputDecoration(border: OutlineInputBorder()))
                      : Text(vitalsController.text.isNotEmpty ? vitalsController.text : 'N/A', style: const TextStyle(fontSize: 14)),
                  color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                  icon: Icons.assignment_late_outlined,
                  title: 'Diagnosis',
                  child: isEditing
                      ? TextFormField(controller: diagnosisController, maxLines: null, decoration: const InputDecoration(border: OutlineInputBorder()))
                      : Text(diagnosisController.text.isNotEmpty ? diagnosisController.text : 'TBD', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  color: Colors.purple.shade700),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoCard(
            icon: Icons.medical_information_outlined,
            title: 'Clinical Summary',
            child: isEditing 
              ? TextFormField(controller: summaryController, maxLines: null, decoration: const InputDecoration(border: OutlineInputBorder()))
              : Text(summaryController.text, style: const TextStyle(fontSize: 14, height: 1.6)),
            color: Colors.teal.shade700),
        const SizedBox(height: 16),
        _InfoCard(
            icon: Icons.calendar_month_outlined,
            title: 'Follow Up',
            child: isEditing
              ? TextFormField(controller: followUpController, maxLines: null, decoration: const InputDecoration(border: OutlineInputBorder()))
              : Text(followUpController.text.isNotEmpty ? followUpController.text : 'No follow-up specified.', style: const TextStyle(fontSize: 14, height: 1.6)),
            color: Colors.green.shade700),
      ],
    );
  }
}

class _MedicinesTab extends StatelessWidget {
  const _MedicinesTab({
    required this.medicinesController,
    required this.isEditing,
  });
  final TextEditingController medicinesController;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: TextFormField(
          controller: medicinesController,
          maxLines: null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter each medicine on a new line',
            labelText: 'Prescribed Medicines',
          ),
        ),
      );
    }

    final medicines = medicinesController.text.split('\n').where((s) => s.isNotEmpty).toList();
    if (medicines.isEmpty) {
      return const Center(
          child: Text('No medicines prescribed.',
              style: TextStyle(color: Colors.grey)));
    }
    return Column(
      children: medicines
          .asMap()
          .entries
          .map((e) => _MedCard(number: e.key + 1, medicine: e.value))
          .toList(),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({required this.number, required this.medicine});
  final int number;
  final String medicine;

  @override
  Widget build(BuildContext context) {
    final parts = medicine.split(':');
    final name = parts.first.trim();
    final details = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withValues(alpha: 0.12),
          child: Text('$number',
              style: const TextStyle(
                  color: Colors.indigo, fontWeight: FontWeight.bold)),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: details.isNotEmpty ? Text(details) : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class _TranscriptTab extends StatelessWidget {
  const _TranscriptTab({required this.transcript});
  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Text(
        transcript.isEmpty ? 'No transcript available.' : transcript,
        style: const TextStyle(fontSize: 14, height: 1.7, color: Colors.black87),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.icon,
      required this.title,
      required this.child,
      required this.color});
  final IconData icon;
  final String title;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
