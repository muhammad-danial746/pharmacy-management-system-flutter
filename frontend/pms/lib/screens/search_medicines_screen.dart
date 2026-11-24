import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/medicine_tile.dart';
import 'medicine_detail_screen.dart';

class SearchMedicinesScreen extends StatefulWidget {
  const SearchMedicinesScreen({super.key, required this.medicines});

  final List<Medicine> medicines;

  @override
  State<SearchMedicinesScreen> createState() => _SearchMedicinesScreenState();
}

class _SearchMedicinesScreenState extends State<SearchMedicinesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lowerQuery = _query.toLowerCase();

    final filtered = widget.medicines.where((m) {
      if (lowerQuery.isEmpty) return false;
      return m.name.toLowerCase().contains(lowerQuery) ||
          m.batchNumber.toLowerCase().contains(lowerQuery) ||
          m.companyName.toLowerCase().contains(lowerQuery);
    }).toList();

    final safe = filtered
        .where(
          (m) =>
              !m.isExpired &&
              !m.isExpiringWithin(const Duration(days: 30)),
        )
        .toList();
    final nearExpiry = filtered
        .where(
          (m) => m.isExpiringWithin(const Duration(days: 30)),
        )
        .toList();
    final expired = filtered.where((m) => m.isExpired).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search medicines',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
      ),
      body: _query.isEmpty
          ? const Center(
              child: Text('Start typing to search medicines.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  context: context,
                  title: 'Safe',
                  medicines: safe,
                  emptyText: 'No safe medicines found.',
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context: context,
                  title: 'Near to Expire',
                  medicines: nearExpiry,
                  emptyText: 'No near-expiry medicines found.',
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context: context,
                  title: 'Expired',
                  medicines: expired,
                  emptyText: 'No expired medicines found.',
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Medicine> medicines,
    required String emptyText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${medicines.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (medicines.isEmpty)
          Text(
            emptyText,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ...medicines.map(
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

