import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfService {
  PdfService._();

  static final PdfService instance = PdfService._();

  Future<String> exportPrescriptionPdf({
    required String consultationId,
    required String patientName,
    required String summary,
    required List<String> medicines,
    required String followUp,
    String diagnosis = '',
    String vitals = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorName = prefs.getString('doctor_name') ?? 'Medical Practitioner';
    final clinicName = prefs.getString('clinic_name') ?? 'Voice AI Health Clinic';

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
                // Letterhead Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(doctorName.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                        pw.Text(clinicName,
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('PRESCRIPTION',
                            style: pw.TextStyle(
                                fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                        pw.Text('ID: $consultationId',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.indigo, thickness: 1.5),
                pw.SizedBox(height: 20),

                // Patient Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(children: [
                              const pw.TextSpan(text: 'Patient: ', style: pw.TextStyle(color: PdfColors.grey700)),
                              pw.TextSpan(
                                  text: patientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ]),
                          ),
                        ],
                      ),
                      pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                          style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),

                // Vitals Row
                if (vitals.isNotEmpty) ...[
                  pw.Text('PHYSICAL EXAMINATION / VITALS',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
                  pw.SizedBox(height: 6),
                  pw.Text(vitals, style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 20),
                ],

                // Diagnosis
                if (diagnosis.isNotEmpty) ...[
                  pw.Text('PROVISIONAL DIAGNOSIS',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
                  pw.SizedBox(height: 6),
                  pw.Text(diagnosis,
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                ],

                // Clinical Summary
                pw.Text('CLINICAL NOTES',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
                pw.SizedBox(height: 6),
                pw.Text(summary, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
                pw.SizedBox(height: 25),

                // Prescribed Medicines
                pw.Text('RX - PRESCRIBED MEDICATIONS',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
                pw.SizedBox(height: 10),
                if (medicines.isEmpty)
                  pw.Text('No medications prescribed.')
                else
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('Medication Name & Details',
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        ],
                      ),
                      ...medicines.map((med) => pw.TableRow(
                            children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(med, style: const pw.TextStyle(fontSize: 11))),
                            ],
                          )),
                    ],
                  ),
                pw.SizedBox(height: 30),

                // Follow Up
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.indigo, width: 3)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('FOLLOW UP INSTRUCTIONS',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(followUp.isNotEmpty ? followUp : 'No specific follow-up instructions.',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),

                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generated via AI Medical Voice Assistant',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                    pw.Text('Physician Signature: _________________',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'prescription_${patientName.replaceAll(' ', '_')}_$consultationId.pdf',
    );
    return 'prescription_$consultationId.pdf';
  }
}
