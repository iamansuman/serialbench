import 'package:flutter/material.dart';

class Usage extends StatelessWidget {
  const Usage({super.key});

  Widget section({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        section(
          title: 'Getting Started',
          body:
              "Connect your microcontroller to your phone via a USB OTG cable. "
              "In settings, select your device from the dropdown, select baud rate and tap Connect. "
              "Thereafter, open any of the Serial tools (Monitor, Plotter). "
              "Android will ask for USB permission the first time you connect.",
        ),
        section(
          title: 'Baud Rate',
          body:
              'Set this in Settings before connecting. It must match the baud rate configured in your microcontroller firmware or you will see garbled data.',
        ),
        section(
          title: 'Serial Monitor',
          body:
              'Shows raw text lines coming from your device.'
              'Useful for debugging and reading log output.',
        ),
        section(title: 'Serial Plotter', body: 'Plots numeric values sent one per line on a live scrolling chart.'),
      ],
    );
  }
}
