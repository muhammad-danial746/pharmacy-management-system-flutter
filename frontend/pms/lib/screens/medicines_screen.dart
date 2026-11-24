import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/medicine_tile.dart';
import 'search_medicines_screen.dart';
import 'medicine_detail_screen.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key, required this.medicines});

  final List<Medicine> medicines;

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.medicines.isEmpty) {
      return const Center(
        child: Text('No medicines stored. Add new records.'),
      );
    }

    final medicines = widget.medicines;

    final safe = medicines
        .where(
          (m) =>
              !m.isExpired &&
              !m.isExpiringWithin(const Duration(days: 30)),
        )
        .toList();
    final nearExpiry = medicines
        .where(
          (m) => m.isExpiringWithin(const Duration(days: 30)),
        )
        .toList();
    final expired = medicines.where((m) => m.isExpired).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SearchMedicinesScreen(medicines: medicines),
                  ),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search medicines',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(
                  text: 'Safe (${safe.length})',
                  icon: const Icon(Icons.check_circle_outline),
                ),
                Tab(
                  text: 'Near Expiry (${nearExpiry.length})',
                  icon: const Icon(Icons.warning_amber_rounded),
                ),
                Tab(
                  text: 'Expired (${expired.length})',
                  icon: const Icon(Icons.cancel),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildListOrEmpty(
                  medicines: safe,
                  emptyText: 'No safe medicines.',
                ),
                _buildListOrEmpty(
                  medicines: nearExpiry,
                  emptyText: 'No near-expiry medicines.',
                ),
                _buildListOrEmpty(
                  medicines: expired,
                  emptyText: 'No expired medicines.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListOrEmpty({
    required List<Medicine> medicines,
    required String emptyText,
  }) {
    if (medicines.isEmpty) {
      return Center(
        child: Text(emptyText),
      );
    }

    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return MedicineTile(
          medicine: medicine,
          onTap: () async {
            final result = await Navigator.of(context).push<Object?>(
              MaterialPageRoute(
                builder: (_) => MedicineDetailScreen(medicine: medicine),
              ),
            );
            if (!context.mounted) return;

            if (result is String && result == 'deleted') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  content: const Text('Medicine deleted'),
                ),
              );
              setState(() {
                widget.medicines.remove(medicine);
              });
            } else if (result is Medicine) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  content: const Text('Medicine updated'),
                ),
              );
              setState(() {
                final i = widget.medicines.indexOf(medicine);
                if (i != -1) {
                  widget.medicines[i] = result;
                }
              });
            }
          },
        );
      },
    );
  }
}

