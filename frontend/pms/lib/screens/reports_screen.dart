import 'package:flutter/material.dart';

import '../main.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, this.medicines = const []});

  final List<Medicine> medicines;

  @override
  Widget build(BuildContext context) {
    final totalMedicines = medicines.length;
    final totalQuantity =
        medicines.fold<int>(0, (sum, m) => sum + m.quantity);
    final near6Months = medicines
        .where((m) => m.isExpiringWithin(const Duration(days: 180)))
        .length;
    final expired = medicines.where((m) => m.isExpired).length;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Basic stock and expiry reports for your pharmacy.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                top: 16,
                                left: 16,
                                right: 16,
                              ),
                              content: const Text(
                                'Stock report export is not wired to storage yet.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export Stock Report'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                top: 16,
                                left: 16,
                                right: 16,
                              ),
                              content: const Text(
                                'Expiry report export is not wired to storage yet.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export Expiry Report'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: medicines.isEmpty
                ? const Center(
                    child: Text(
                      'No medicines available to generate reports.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ReportSummaryRow(
                        label: 'Total distinct medicines',
                        value: '$totalMedicines',
                      ),
                      _ReportSummaryRow(
                        label: 'Total quantity in stock',
                        value: '$totalQuantity',
                      ),
                      _ReportSummaryRow(
                        label: 'Near expiry within 6 months',
                        value: '$near6Months',
                      ),
                      _ReportSummaryRow(
                        label: 'Expired medicines',
                        value: '$expired',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Stock Report',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildTableHeader(
                        context,
                        columns: const ['Name', 'Batch', 'Qty'],
                      ),
                      const SizedBox(height: 4),
                      ...medicines.map(
                        (m) => _ReportRow(
                          cells: [
                            m.name,
                            m.batchNumber,
                            m.quantity.toString(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Expiry Report',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildTableHeader(
                        context,
                        columns: const ['Name', 'Expiry', 'Status'],
                      ),
                      const SizedBox(height: 4),
                      ...medicines.map(
                        (m) {
                          final isExpired = m.isExpired;
                          final isNear =
                              m.isExpiringWithin(const Duration(days: 180));
                          String status = 'Safe';
                          if (isExpired) {
                            status = 'Expired';
                          } else if (isNear) {
                            status = 'Near Expiry';
                          }
                          final d = m.expiryDate;
                          final formattedDate =
                              '${d.day.toString().padLeft(2, '0')}/'
                              '${d.month.toString().padLeft(2, '0')}/'
                              '${d.year}';
                          return _ReportRow(
                            cells: [
                              m.name,
                              formattedDate,
                              status,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context,
      {required List<String> columns}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final flex = index == 0 ? 3 : 2;
          return Expanded(
            flex: flex,
            child: Text(
              columns[index],
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          );
        }),
      ),
    );
  }
}

class _ReportSummaryRow extends StatelessWidget {
  const _ReportSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.cells});

  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: List.generate(cells.length, (index) {
          final flex = index == 0 ? 3 : 2;
          return Expanded(
            flex: flex,
            child: Text(
              cells[index],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }),
      ),
    );
  }
}

