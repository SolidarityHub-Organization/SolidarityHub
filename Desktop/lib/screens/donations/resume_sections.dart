import 'package:flutter/material.dart';

class DonationSummaryCard extends StatelessWidget {
  final String title;
  final int available;
  final int assigned;
  final IconData icon;

  const DonationSummaryCard({
    super.key,
    required this.title,
    required this.available,
    required this.assigned,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text('Disp: $available', style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Asig: $assigned', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}