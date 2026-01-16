import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/models/medicine_log.dart';
import 'package:myapp/utils/compliance_calculator.dart';
import 'package:intl/intl.dart';

Future<void> generateAndSharePdf(
  double overallCompliance,
  List<Medicine> medicines,
  List<MedicineLog> logs,
  String patientName,
) async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final formattedDate = DateFormat('yyyy-MM-dd').format(now);

  PdfColor complianceColor;
  if (overallCompliance < 50) {
    complianceColor = PdfColors.red;
  } else if (overallCompliance > 80) {
    complianceColor = PdfColors.green;
  } else {
    complianceColor = PdfColors.black;
  }

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Patient Status Report for $patientName',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text('Date: $formattedDate'),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  'Overall Adherence: ${overallCompliance.toStringAsFixed(1)}%',
                  style: pw.TextStyle(
                      fontSize: 20,
                      color: complianceColor,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Medicine Name', 'Frequency', 'Compliance %', 'Status'],
              data: medicines.map((med) {
                final compliance = calculateMedicineCompliance(med, logs);
                return [
                  med.name,
                  med.frequency,
                  '${compliance.toStringAsFixed(1)}%',
                  compliance > 80 ? 'On Track' : 'Needs Attention'
                ];
              }).toList(),
            ),
            pw.Spacer(),
            pw.Footer(
              title: pw.Text('Verified by Malaysian Pharmacist AI',
                  style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        );
      },
    ),
  );

  await Printing.sharePdf(
      bytes: await pdf.save(), filename: 'patient_report.pdf');
}
