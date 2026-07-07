import 'package:flutter/material.dart';
import '../data/models/consultation.dart';
import '../data/repositories/consultation_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final List<Consultation> _history = ConsultationRepository.instance.consultations;

  List<Consultation> get history => List.unmodifiable(_history);
}
