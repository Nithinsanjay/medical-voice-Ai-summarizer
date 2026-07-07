import 'package:flutter/material.dart';
import '../data/models/consultation.dart';
import '../data/repositories/consultation_repository.dart';

class ConsultationViewModel extends ChangeNotifier {
  ConsultationViewModel() {
    _loadConsultations();
  }

  final List<Consultation> _consultations = [];
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  List<Consultation> get consultations => List.unmodifiable(_consultations);

  void _loadConsultations() {
    _consultations.addAll(ConsultationRepository.instance.consultations);
    notifyListeners();
  }

  void addConsultation(Consultation consultation) {
    _consultations.insert(0, consultation);
    ConsultationRepository.instance.addConsultation(consultation);
    notifyListeners();
  }

  void setRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }
}
