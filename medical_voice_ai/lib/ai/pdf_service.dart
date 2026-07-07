class PdfService {
  PdfService._();

  static final PdfService instance = PdfService._();

  Future<String> exportPrescriptionPdf(String consultationId, String summary) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return '/storage/emulated/0/Download/prescription_$consultationId.pdf';
  }
}
