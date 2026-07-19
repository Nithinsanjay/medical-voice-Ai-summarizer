import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  PdfService._();

  static final PdfService instance = PdfService._();

  Future<String> exportPrescriptionPdf({
    required String consultationId,
    required String patientName,
    required String summary,
    required List<String> medicines,
    required String followUp,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PRESCRIPTION SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                    pw.Text(
                      'AI Medical Voice Assistant',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.Divider(color: PdfColors.teal, thickness: 2),
                pw.SizedBox(height: 20),

                // Patient Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Patient Name: $patientName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Consultation ID:'),
                        pw.Text(consultationId, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Clinical Summary
                pw.Text('Clinical Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal700)),
                pw.SizedBox(height: 5),
                pw.Text(summary, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 25),

                // Prescribed Medicines
                pw.Text('Prescribed Medicines', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal700)),
                pw.SizedBox(height: 5),
                if (medicines.isEmpty)
                  pw.Text('No medications prescribed.')
                else
                  ...medicines.map((med) => pw.Bullet(
                        text: med,
                        style: const pw.TextStyle(fontSize: 12),
                        bulletSize: 5,
                      )),
                pw.SizedBox(height: 25),

                // Follow Up
                pw.Text('Follow Up Instructions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal700)),
                pw.SizedBox(height: 5),
                pw.Text(followUp.isNotEmpty ? followUp : 'No specific follow-up instructions.', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'prescription_$consultationId.pdf',
    );
    return 'prescription_$consultationId.pdf';
  }
}
