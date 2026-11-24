import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/medicine_tile.dart';
import 'medicine_detail_screen.dart';

class ExpiryScreen extends StatelessWidget {
  const ExpiryScreen({super.key, required this.medicines});

  final List<Medicine> medicines;

  @override
  Widget build(BuildContext context) {
    final nearExpiry = medicines
        .where(
          (m) => m.isExpiringWithin(const Duration(days: 180)),
        )
        .toList();
    final expiredList = medicines.where((m) => m.isExpired).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Near Expiry (within 6 months)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (nearExpiry.isEmpty)
          const Text('No near-expiry medicines.')
        else
          ...nearExpiry.map(
            (m) => MedicineTile(
              medicine: m,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MedicineDetailScreen(medicine: m),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Expired Medicines',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (expiredList.isEmpty)
          const Text('No expired medicines.')
        else
          ...expiredList.map(
            (m) => MedicineTile(
              medicine: m,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MedicineDetailScreen(medicine: m),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

