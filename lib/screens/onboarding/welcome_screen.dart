import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/screens/add_medicine_screen.dart';
import 'package:myapp/screens/caregiver/add_caregiver_screen.dart';
import 'package:myapp/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: TexturedBackground(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _isLastPage = index == 2);
              },
              children: [
                _buildPage(
                  title: 'Your Personal Health Assistant',
                  subtitle:
                      'Never miss a dose again. Manage your medications with AI-powered ease.',
                  icon: Icons.health_and_safety,
                  color: Colors.teal,
                ),
                _buildPage(
                  title: 'Setup Your First Medicine',
                  subtitle:
                      'Let\'s get started by adding one medication you take regularly.',
                  icon: Icons.medication,
                  color: Colors.blue,
                  action: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const AddMedicineScreen())),
                    child: const Text('Add My First Med'),
                  ),
                ),
                _buildPage(
                  title: 'Involve a Caregiver',
                  subtitle:
                      'Add a family member or friend to help you stay on track.',
                  icon: Icons.group_add,
                  color: Colors.orange,
                  action: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const AddCaregiverScreen())),
                    child: const Text('Invite a Caregiver'),
                  ),
                ),
              ],
            ),
            Container(
              alignment: const Alignment(0, 0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => _finishOnboarding(),
                    child: const Text('SKIP'),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: WormEffect(
                      dotColor: Colors.grey.shade300,
                      activeDotColor: theme.colorScheme.primary,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                  _isLastPage
                      ? TextButton(
                          onPressed: () => _finishOnboarding(),
                          child: const Text('DONE'),
                        )
                      : TextButton(
                          onPressed: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                          child: const Text('NEXT'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (action != null) ...[
            const SizedBox(height: 40),
            action,
          ],
        ],
      ),
    );
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTour', true);
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => const LoginScreen()));
    }
  }
}
