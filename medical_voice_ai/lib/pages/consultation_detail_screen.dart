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
  int _selectedTab = 0;

  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      await TtsService.instance.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final c = widget.consultation;
      final text =
          'Summary: ${c.summary}. Medicines: ${c.medicines.join('. ')}. Follow up: ${c.followUp}';
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
        summary: c.summary,
        medicines: c.medicines,
        followUp: c.followUp,
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
        return _SummaryTab(summary: c.summary, followUp: c.followUp);
      case 1:
        return _MedicinesTab(medicines: c.medicines);
      case 2:
        return _TranscriptTab(transcript: c.transcript);
      default:
        return const SizedBox();
    }
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.summary, required this.followUp});
  final String summary;
  final String followUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
            icon: Icons.medical_information_outlined,
            title: 'Clinical Summary',
            text: summary,
            color: Colors.teal.shade700),
        const SizedBox(height: 16),
        _InfoCard(
            icon: Icons.calendar_month_outlined,
            title: 'Follow Up',
            text: followUp.isNotEmpty ? followUp : 'No follow-up specified.',
            color: Colors.green.shade700),
      ],
    );
  }
}

class _MedicinesTab extends StatelessWidget {
  const _MedicinesTab({required this.medicines});
  final List<String> medicines;

  @override
  Widget build(BuildContext context) {
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
      required this.text,
      required this.color});
  final IconData icon;
  final String title;
  final String text;
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
          Text(text,
              style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
