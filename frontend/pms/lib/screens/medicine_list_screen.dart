import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'medicines_screen.dart';
import 'expiry_screen.dart';
import 'suppliers_screen.dart';
import 'reports_screen.dart';
import 'add_medicine_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

enum _BottomTab {
  dashboard,
  medicines,
  expiry,
  suppliers,
  reports,
}

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final List<Medicine> _medicines = [];
  _BottomTab _currentTab = _BottomTab.dashboard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _loading = true);
    try {
      final medicines = await ApiService.getMedicines();
      setState(() {
        _medicines
          ..clear()
          ..addAll(medicines);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load medicines: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addMedicine(Medicine medicine) {
    setState(() {
      _medicines.add(medicine);
    });
  }

  Future<void> _navigateToAddMedicine() async {
    final result = await Navigator.of(context).push<Medicine>(
      MaterialPageRoute(
        builder: (_) => const AddMedicineScreen(),
      ),
    );

    if (result != null) {
      _addMedicine(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = _medicines.where((m) => m.isExpired).length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Pharmacy Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(medicines: _medicines),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ApiService.clearToken();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(expired: expired),
      floatingActionButton: _currentTab == _BottomTab.medicines ||
              _currentTab == _BottomTab.dashboard
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddMedicine,
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentTab = _BottomTab.values[index];
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Expiry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Suppliers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildBody({required int expired}) {
    switch (_currentTab) {
      case _BottomTab.dashboard:
        return DashboardScreen(
          medicines: _medicines,
          expiredCount: expired,
        );
      case _BottomTab.medicines:
        return MedicinesScreen(medicines: _medicines);
      case _BottomTab.expiry:
        return ExpiryScreen(medicines: _medicines);
      case _BottomTab.suppliers:
        return const SuppliersScreen();
      case _BottomTab.reports:
        return ReportsScreen(medicines: _medicines);
    }
  }
}
