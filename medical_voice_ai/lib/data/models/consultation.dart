class Consultation {
  Consultation({
    required this.id,
    required this.patientName,
    required this.dateTime,
    required this.chiefComplaint,
    required this.transcript,
    required this.summary,
    required this.medicines,
    required this.followUp,
  });

  final String id;
  final String patientName;
  final DateTime dateTime;
  final String chiefComplaint;
  final String transcript;
  final String summary;
  final List<String> medicines;
  final String followUp;
}
