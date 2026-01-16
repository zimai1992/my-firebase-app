import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:myapp/models/medicine.dart';
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
            'Extract the medicine name, dosage, and frequency from the image. '
            'Also provide a recommendation note for the medicine. '
            'Also analyze for Food Interactions (e.g., avoid milk, alcohol) and Activity Warnings (e.g., drowsiness/driving). '
            'Add these to a new JSON key called lifestyle_warnings. '
            'Format the output AS A RAW JSON OBJECT with the following keys: '
            '"name", "dosage", "frequency", "recommendation_note", and "lifestyle_warnings". '
            'Do not include any markdown formatting like ```json or ```. Return ONLY the JSON string.'),
      );
      _initialized = true;
    } catch (e) {
      developer.log('Failed to initialize Gemini model: $e', name: 'GeminiService');
    }
  }

  Future<String> analyzeMedicine(Uint8List imageBytes) async {
    if (!_initialized) return '{"error": "Service not initialized"}';
    try {
      final content = [Content.multi([InlineDataPart('image/jpeg', imageBytes)])];
      final response = await _model.generateContent(content);
      return _cleanResponse(response.text);
    } catch (e) {
      return '{"error": "$e"}';
    }
  }

  Future<String> checkInteractions(List<Medicine> medicines) async {
    if (!_initialized) return '{"error": "Service not initialized"}';
    try {
      final medList = medicines.map((m) => '${m.name} (${m.dosage})').join(', ');
      final prompt = 'Analyze the following list of medications for potential harmful interactions: $medList. '
          'Provide a concise summary of any warnings and advice. If no significant interactions, say "No major interactions detected." '
          'Format as a clear, bulleted list for a patient.';
      
      final interactionModel = FirebaseAI.vertexAI().generativeModel(model: 'gemini-1.5-flash');
      final response = await interactionModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response from model.';
    } catch (e) {
      return 'Error checking interactions: $e';
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
