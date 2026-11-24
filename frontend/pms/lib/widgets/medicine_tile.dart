import 'package:flutter/material.dart';

import '../main.dart';

class MedicineTile extends StatelessWidget {
  const MedicineTile({
    super.key,
    required this.medicine,
    this.onTap,
  });

  final Medicine medicine;
  final VoidCallback? onTap;

  Color _statusColor(BuildContext context) {
    if (medicine.isExpired) return Colors.red.withValues(alpha: 0.1);
    if (medicine.isExpiringWithin(const Duration(days: 30))) {
      return Colors.orange.withValues(alpha: 0.08);
    }
    return Colors.green.withValues(alpha: 0.05);
  }

  String _statusText() {
    if (medicine.isExpired) return 'Expired';

    final now = DateTime.now();
    final diff = medicine.expiryDate.difference(now);
    final totalDays = diff.inDays;

    if (totalDays <= 0) return 'Expired';

    final months = totalDays ~/ 30;
    final days = totalDays % 30;

    if (months > 0 && days > 0) {
      return '$months month(s) $days day(s) remaining';
    } else if (months > 0) {
      return '$months month(s) remaining';
    } else {
      return '$days day(s) remaining';
    }
  }

  Color _statusTextColor() {
    if (medicine.isExpired) return Colors.red;
    if (medicine.isExpiringWithin(const Duration(days: 7))) {
      return Colors.deepOrange;
    }
    if (medicine.isExpiringWithin(const Duration(days: 30))) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final date = medicine.expiryDate;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Card(
      color: _statusColor(context),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          medicine.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (medicine.batchNumber.isNotEmpty)
              Text('Batch: ${medicine.batchNumber}'),
            if (medicine.companyName.isNotEmpty)
              Text('Company: ${medicine.companyName}'),
            const SizedBox(height: 2),
            Text('Expiry: $formattedDate'),
            const SizedBox(height: 2),
            Text(
              _statusText(),
              style: TextStyle(
                color: _statusTextColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication, size: 20),
            const SizedBox(height: 4),
            Text('Qty: ${medicine.quantity}'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
