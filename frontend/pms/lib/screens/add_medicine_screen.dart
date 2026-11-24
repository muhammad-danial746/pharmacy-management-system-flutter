// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key, this.initialMedicine});

  final Medicine? initialMedicine;

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCompany;
  DateTime? _selectedDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMedicine;
    if (initial != null) {
      _nameController.text = initial.name;
      _batchController.text = initial.batchNumber;
      _quantityController.text = initial.quantity.toString();
      _selectedCompany = initial.companyName;
      _selectedDate = initial.expiryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  List<String> get _companyOptions => const [
        'HealthCare Distributors',
        'Global Pharma Ltd.',
        'Wellness Medical Supplies',
      ];

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedCompany == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an expiry date')),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final draft = Medicine(
        id: widget.initialMedicine?.id,
        name: _nameController.text.trim(),
        batchNumber: _batchController.text.trim(),
        companyName: _selectedCompany!,
        quantity: quantity,
        expiryDate: _selectedDate!,
      );

      final Medicine saved;
      if (draft.id != null) {
        saved = await ApiService.updateMedicine(draft.id!, draft);
      } else {
        saved = await ApiService.createMedicine(draft);
      }

      Navigator.of(context).pop<Medicine>(saved);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialMedicine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter batch number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter quantity';
                  }
                  final qty = int.tryParse(value.trim());
                  if (qty == null || qty <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedCompany,
                items: _companyOptions
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCompany = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a company';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No expiry date chosen'
                          : 'Expiry: ${_selectedDate!.day.toString().padLeft(2, '0')}/'
                              '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                              '${_selectedDate!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickExpiryDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Update Medicine' : 'Save Medicine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
