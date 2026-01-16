import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final canLaunch = await canLaunchUrl(uri);

    if (canLaunch) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                subtitle: Text(_version.isEmpty ? 'Loading...' : _version),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () =>
                    _launchURL('https://www.google.com'), // Placeholder
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Rate Us on the Store'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final isAvailable = await _inAppReview.isAvailable();

                  if (isAvailable) {
                    _inAppReview.requestReview();
                  } else {
                    if (!mounted) return;
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                          content: Text(
                              'In-app review is not available on this device.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
