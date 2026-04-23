import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SupportCard(
            title: 'Need help planning your trek?',
            body:
                'Use the Planner tab to choose destination, days, and budget. The app validates realistic trek durations automatically.',
          ),
          SizedBox(height: 12),
          _SupportCard(
            title: 'Account Support',
            body:
                'Use Profile > Edit Profile to update your account details and Profile > Change Password to secure your account.',
          ),
          SizedBox(height: 12),
          _SupportCard(
            title: 'Connectivity Help',
            body:
                'If the app cannot connect, make sure backend is running and your phone is on the same WiFi as your laptop.',
          ),
          SizedBox(height: 12),
          _SupportCard(
            title: 'Contact',
            body:
                'For project support, contact your project admin/supervisor with screenshots and the exact error message.',
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String body;

  const _SupportCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
