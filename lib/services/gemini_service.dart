import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/models/medicine_log.dart';
import 'package:myapp/models/prediction_result.dart';
import 'dart:developer' as developer;

class GeminiService {
  late final GenerativeModel _model;
  bool _initialized = false;

  GeminiService() {
    try {
      _model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.text(
            'You are a Malaysian Pharmacist. You are an expert at identifying medications. '
            'Extract the medicine name, generic name (active ingredient), dosage, and frequency from the image. '
            'Also provide a recommendation note for the medicine. '
            'CRITICAL: Analyze for Special Administration Instructions. Examples: '
            '- "Must stay upright for 30 minutes" (e.g., for Alendronate/Bisphosphonates). '
            '- "Take on an empty stomach". '
            '- "Swallow whole, do not crush". '
            'Also analyze for Food Interactions (e.g., avoid milk, alcohol) and Activity Warnings (e.g., drowsiness/driving). '
            'Combine all strict administration rules and lifestyle warnings into the "lifestyle_warnings" key. '
            'Format the output AS A RAW JSON OBJECT with the following keys: '
            '"name", "generic_name", "dosage", "frequency", "recommendation_note", and "lifestyle_warnings". '
            'Do not include any markdown formatting like ```json or ```. Return ONLY the JSON string.'),
      );
      _initialized = true;
    } catch (e) {
      developer.log('Failed to initialize Gemini model: $e',
          name: 'GeminiService');
    }
  }

  Future<String> analyzeMedicine(Uint8List imageBytes) async {
    if (!_initialized) return '{"error": "Service not initialized"}';
    try {
      final content = [
        Content.multi([InlineDataPart('image/jpeg', imageBytes)])
      ];
      final response = await _model.generateContent(content);
      return _cleanResponse(response.text);
    } catch (e) {
      return '{"error": "$e"}';
    }
  }

  Future<String> checkInteractions(List<Medicine> medicines) async {
    if (!_initialized) return '{"error": "Service not initialized"}';
    try {
      final medList =
          medicines.map((m) => '${m.name} (${m.dosage})').join(', ');
      final prompt =
          'Analyze the following list of medications for potential harmful interactions: $medList. '
          'Provide a concise summary of any warnings and advice. If no significant interactions, say "No major interactions detected." '
          'Format as a clear, bulleted list for a patient.';

      final interactionModel =
          FirebaseAI.vertexAI().generativeModel(model: 'gemini-1.5-flash');
      final response =
          await interactionModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response from model.';
    } catch (e) {
      return 'Error checking interactions: $e';
    }
  }

  Future<PredictionResult> predictRunoutDate(
      Medicine med, List<MedicineLog> logs) async {
    if (!_initialized) return PredictionResult.error('Service not initialized');

    try {
      // Calculate usage in last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentLogs = logs
          .where((l) =>
              l.medicineId == med.id && l.timestamp.isAfter(thirtyDaysAgo))
          .toList();

      final prompt = '''
Medicine: ${med.name}
Current stock: ${med.currentStock} pills
Scheduled frequency: ${med.frequency}
Actual doses logged (last 30 days): ${recentLogs.length}
Threshold for low stock alert: ${med.lowStockThreshold}

Based on this data, predict when the patient will run out of this medicine.

Return ONLY a JSON object (no markdown):
{
  "runoutDate": "YYYY-MM-DD",
  "confidence": "High|Medium|Low",
  "message": "Brief user-friendly message (e.g., 'Refill in 3 days' or 'Stock OK for 2 weeks')"
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final cleanText = _cleanResponse(response.text);
      final data = jsonDecode(cleanText) as Map<String, dynamic>;

      return PredictionResult.fromJson(data);
    } catch (e) {
      developer.log('Prediction error: $e');
      return PredictionResult.error('Unable to predict refill date');
    }
  }

  Future<String> askPharmacist(
      String question, List<Medicine> medicines) async {
    if (!_initialized) return 'Service not initialized. Please try again.';

    try {
      final medList =
          medicines.where((m) => !m.isStopped).map((m) => m.name).join(', ');
      final context = medList.isNotEmpty
          ? 'Patient is taking: $medList.'
          : 'Patient has no active medicines.';

      final prompt = '''
You are a knowledgeable Malaysian pharmacist providing patient education.

$context

Patient question: "$question"

Provide a helpful, accurate, and easy-to-understand answer. 
- If it's a serious concern, advise seeing a doctor.
- Be warm and professional.
- Keep answers concise (2-3 paragraphs max).
- Use simple language.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          'I apologize, but I couldn\'t generate a response. Please try rephrasing your question.';
    } catch (e) {
      developer.log('Pharmacist chat error: $e');
      return 'I\'m having trouble right now. Please try again in a moment.';
    }
  }

  Future<String> analyzeHealthData(String rawData) async {
    if (!_initialized) return '{"error": "Service not initialized"}';
    try {
      final prompt = '''
You are a medical consultant analyzing a patient's medication adherence and health readings for their doctor.

Patient Data:
$rawData

Provide a 2-3 sentence professional clinical summary. 
- Focus on overall adherence.
- Note any concerning trends in vitals (BP, Sugar, INR).
- Suggest areas for clinical focus or adjustment if necessary.
- Use a professional, objective tone.

Return the summary as plain text. No markdown formatting.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Summary unavailable at this time.';
    } catch (e) {
      developer.log('Health data analysis error: $e');
      return 'Clinician Review Recommended: Adherence analysis failed due to service error.';
    }
  }

  Future<String> performAdvancedAnalysis(String fullHistoryData) async {
    if (!_initialized) return '{"error": "Service not initialized"}';
    try {
      final prompt = '''
You are "The Clinical Oracle," a super-advanced medical AI analyzing months of patient behavior and physiological data.

Goal: Identify subtle correlations between medication adherence (timing, misses) and health outcomes (BP, Glucose).

Data Scope:
$fullHistoryData

Your analysis MUST include:
1. 📈 Longitudinal Trend: How has vitals control changed over the last 90 days?
2. 🕒 Timing Correlation: Does taking medicine >30 mins late correlate with higher readings? (Be specific if data allows).
3. 🧘 Optimization Strategy: What is the patient's "Golden Window" for maximum efficacy based on their history?
4. 🩺 Risk Forecast: Predictive warnings based on current adherence patterns.

Tone: Deeply clinical, insight-driven, and empowering.
Format: Use professional medical headings. Avoid generic advice.
''';

      final oracleModel =
          FirebaseAI.vertexAI().generativeModel(model: 'gemini-1.5-pro'); // Use Pro for deep analysis
      final response = await oracleModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'The Oracle is silent. Insufficient data for deep analysis.';
    } catch (e) {
      developer.log('Oracle analysis error: $e');
      return 'Oracle Sync Failure: High-fidelity pattern analysis requires more consistent data logging.';
    }
  }

  String _cleanResponse(String? text) {
    if (text == null || text.isEmpty) return '{"error": "No response"}';
    String cleanText = text.trim();
    if (cleanText.startsWith('```')) {
      cleanText = cleanText.replaceAll(RegExp(r'^```json\n?'), '');
      cleanText = cleanText.replaceAll(RegExp(r'\n?```$'), '');
    }
    return cleanText;
  }
}
