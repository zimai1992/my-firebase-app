
import 'dart:typed_data';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:developer' as developer;

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
      : _model = FirebaseVertexAI.instance.generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.text(
              'You are a Malaysian Pharmacist. You are an expert at identifying medications. Extract the medicine name, dosage, and frequency from the image. Also provide a recommendation note for the medicine. Also analyze for Food Interactions (e.g., avoid milk, alcohol) and Activity Warnings (e.g., drowsiness/driving). Add these to a new JSON key called lifestyle_warnings. Format the output as a JSON object with the keys "name", "dosage", "frequency", "recommendation_note", and "lifestyle_warnings".'),
        );

  Future<String> analyzeMedicine(Uint8List imageBytes) async {
    try {
      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);

      return response.text ??
          '{"error": "Failed to get a response from the model."}';
    } catch (e, s) {
      developer.log(
        'Error analyzing medicine image with Gemini',
        name: 'GeminiService',
        error: e,
        stackTrace: s,
        level: 1000, // SEVERE
      );
      return '{"error": "Failed to analyze image: $e"}';
    }
  }
}
