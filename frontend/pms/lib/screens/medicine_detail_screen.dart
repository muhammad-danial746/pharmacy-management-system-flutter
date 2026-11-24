// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'add_medicine_screen.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final date = medicine.expiryDate;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    final isExpired = medicine.isExpired;
    final isNear7 = medicine.isExpiringWithin(const Duration(days: 7));
    final isNear30 = medicine.isExpiringWithin(const Duration(days: 30));

    String status;
    Color statusColor;
    if (isExpired) {
      status = 'Expired';
      statusColor = Colors.red;
    } else if (isNear7) {
      status = 'Expiring within 7 days';
      statusColor = Colors.deepOrange;
    } else if (isNear30) {
      status = 'Expiring within 30 days';
      statusColor = Colors.orange;
    } else {
      status = 'Safe';
      statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                status,
                style: TextStyle(color: statusColor),
              ),
              backgroundColor: statusColor.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Batch Number', value: medicine.batchNumber),
            const SizedBox(height: 12),
            _DetailRow(label: 'Company Name', value: medicine.companyName),
            const SizedBox(height: 12),
            _DetailRow(label: 'Quantity', value: medicine.quantity.toString()),
            const SizedBox(height: 12),
            _DetailRow(label: 'Expiry Date', value: formattedDate),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<Medicine>(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddMedicineScreen(initialMedicine: medicine),
                        ),
                      );
                      if (updated != null) {
                        Navigator.of(context).pop<Medicine>(updated);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Medicine'),
                          content: const Text(
                            'Are you sure you want to delete this medicine?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          if (medicine.id != null) {
                            await ApiService.deleteMedicine(medicine.id!);
                          }
                          Navigator.of(context).pop<String>('deleted');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
