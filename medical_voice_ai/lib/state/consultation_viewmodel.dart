import 'package:flutter/material.dart';
import '../data/models/consultation.dart';
import '../data/repositories/consultation_repository.dart';

class ConsultationViewModel extends ChangeNotifier {
  ConsultationViewModel() {
    loadConsultations();
  }

  bool _isRecording = false;
  bool _isLoading = false;

  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  List<Consultation> get consultations => ConsultationRepository.instance.consultations;

  Future<void> loadConsultations() async {
    _isLoading = true;
    notifyListeners();
    try {
      await ConsultationRepository.instance.init();
    } catch (e) {
      debugPrint('Error loading consultations: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addConsultation(Consultation consultation) async {
    await ConsultationRepository.instance.addConsultation(consultation);
    notifyListeners();
  }

  void setRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }
}
