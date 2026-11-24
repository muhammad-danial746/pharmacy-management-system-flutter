import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/medicine_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.medicines});

  final List<Medicine> medicines;

  @override
  Widget build(BuildContext context) {
    final nearExpiry = medicines
        .where(
          (m) => m.isExpiringWithin(const Duration(days: 180)),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiry Notifications'),
      ),
      body: nearExpiry.isEmpty
          ? const Center(
              child: Text('No medicines expiring within 6 months.'),
            )
          : ListView.builder(
              itemCount: nearExpiry.length,
              itemBuilder: (context, index) {
                final medicine = nearExpiry[index];
                return MedicineTile(medicine: medicine);
              },
            ),
    );
  }
}

