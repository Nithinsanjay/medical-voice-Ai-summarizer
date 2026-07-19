import 'package:flutter/material.dart';
import '../data/models/consultation.dart';
import '../data/repositories/consultation_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Consultation> get history => ConsultationRepository.instance.consultations;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ConsultationRepository.instance.init();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteConsultation(String id) async {
    await ConsultationRepository.instance.deleteConsultation(id);
    notifyListeners();
  }
}
