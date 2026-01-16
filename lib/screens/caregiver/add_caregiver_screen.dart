import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/medicine_provider.dart';

class AddCaregiverScreen extends StatefulWidget {
  const AddCaregiverScreen({super.key});

  @override
  _AddCaregiverScreenState createState() => _AddCaregiverScreenState();
}

class _AddCaregiverScreenState extends State<AddCaregiverScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Caregiver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Caregiver Email',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                if (email.isNotEmpty) {
                  Provider.of<MedicineProvider>(context, listen: false)
                      .addCaregiver(email);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Caregiver'),
            ),
          ],
        ),
      ),
    );
  }
}
