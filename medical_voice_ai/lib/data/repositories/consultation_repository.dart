import '../models/consultation.dart';

class ConsultationRepository {
  ConsultationRepository._();

  static final ConsultationRepository instance = ConsultationRepository._();

  final List<Consultation> _consultations = [];

  List<Consultation> get consultations => List.unmodifiable(_consultations);

  void addConsultation(Consultation consultation) {
    _consultations.insert(0, consultation);
  }
}
