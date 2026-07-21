import 'dart:convert';
import '../models/consultation.dart';
import '../database/database_service.dart';

class ConsultationRepository {
  ConsultationRepository._();

  static final ConsultationRepository instance = ConsultationRepository._();

  final List<Consultation> _consultations = [];

  List<Consultation> get consultations => List.unmodifiable(_consultations);

  Future<void> init() async {
    _consultations.clear();
    final list = await DatabaseService.instance.loadConsultations();
    for (final map in list) {
      _consultations.add(Consultation(
        id: map['id'] as String,
        patientName: map['patientName'] as String,
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
        chiefComplaint: map['chiefComplaint'] as String,
        transcript: map['transcript'] as String,
        summary: map['summary'] as String,
        medicines: List<String>.from(json.decode(map['medicines'] as String)),
        followUp: map['followUp'] as String,
        diagnosis: map['diagnosis'] as String? ?? '',
        vitals: map['vitals'] as String? ?? '',
      ));
    }
  }

  Future<void> addConsultation(Consultation consultation) async {
    _consultations.insert(0, consultation);
    await DatabaseService.instance.insertConsultation({
      'id': consultation.id,
      'patientName': consultation.patientName,
      'dateTime': consultation.dateTime.millisecondsSinceEpoch,
      'chiefComplaint': consultation.chiefComplaint,
      'transcript': consultation.transcript,
      'summary': consultation.summary,
      'medicines': json.encode(consultation.medicines),
      'followUp': consultation.followUp,
      'diagnosis': consultation.diagnosis,
      'vitals': consultation.vitals,
    });
  }

  Future<void> deleteConsultation(String id) async {
    _consultations.removeWhere((item) => item.id == id);
    await DatabaseService.instance.deleteConsultation(id);
  }

  Future<void> updateConsultation(Consultation consultation) async {
    final index = _consultations.indexWhere((item) => item.id == consultation.id);
    if (index != -1) {
      _consultations[index] = consultation;
    }
    await DatabaseService.instance.insertConsultation({
      'id': consultation.id,
      'patientName': consultation.patientName,
      'dateTime': consultation.dateTime.millisecondsSinceEpoch,
      'chiefComplaint': consultation.chiefComplaint,
      'transcript': consultation.transcript,
      'summary': consultation.summary,
      'medicines': json.encode(consultation.medicines),
      'followUp': consultation.followUp,
      'diagnosis': consultation.diagnosis,
      'vitals': consultation.vitals,
    });
  }
}
