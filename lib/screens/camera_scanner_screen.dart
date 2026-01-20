import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/screens/add_medicine_screen.dart';
import 'package:myapp/services/gemini_service.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  Map<String, String>? _extractedData;
  bool _isLoading = false;

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
        _extractedData = null; // Clear previous data
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await _geminiService.analyzeMedicine(await _image!.readAsBytes());
      debugPrint('Gemini Response: $response'); // LOGGING

      final data = jsonDecode(response) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${data['error']}')),
        );
        return;
      }

      setState(() {
        _extractedData =
            data.map((key, value) => MapEntry(key, value.toString()));
      });
    } catch (e) {
      debugPrint('Analysis Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addMedicine() {
    if (_extractedData == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(
          initialName: _extractedData!['name'],
          initialGenericName: _extractedData!['generic_name'],
          initialDosage: _extractedData!['dosage'],
          initialFrequency: _extractedData!['frequency'],
          initialSpecialInstructions: [
            _extractedData!['special_instructions'],
            _extractedData!['lifestyle_warnings'],
            _extractedData!['recommendation_note']
          ].where((s) => s != null && s.isNotEmpty && s != 'null').join('. '),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Prescription')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_image != null)
              kIsWeb
                  ? Image.network(
                      _image!.path,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_image!.path),
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Picture'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeImage,
                icon: _isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.analytics),
                label: const Text('Analyze Prescription'),
              ),
            if (_extractedData != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${_extractedData!['name']}'),
                    Text('Dosage: ${_extractedData!['dosage']}'),
                    Text('Frequency: ${_extractedData!['frequency']}'),
                    Text(
                        'Recommendation: ${_extractedData!['recommendation_note']}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addMedicine,
                      child: const Text('Add Medicine'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
