import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class Medicine {
  Medicine({
    this.id,
    required this.name,
    required this.batchNumber,
    required this.companyName,
    required this.quantity,
    required this.expiryDate,
  });

  final String? id;
  final String name;
  final String batchNumber;
  final String companyName;
  final int quantity;
  final DateTime expiryDate;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool isExpiringWithin(Duration duration) {
    final now = DateTime.now();
    return !isExpired && expiryDate.isBefore(now.add(duration));
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] as String?,
      name: json['name'] as String,
      batchNumber: json['batchNumber'] as String,
      companyName: json['companyName'] as String,
      quantity: json['quantity'] as int,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
    );
  }
}
