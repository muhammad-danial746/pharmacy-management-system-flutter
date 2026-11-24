import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/supplier.dart';

class ApiService {
  // Change to your machine's IP if running on a physical device or Android emulator (use 10.0.2.2 for emulator)
  static const String baseUrl = 'http://localhost:3000/api';
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Login failed');
  }

  // ── Medicines ─────────────────────────────────────────────────────────────

  static Future<List<Medicine>> getMedicines(
      {String? status, String? search}) async {
    final params = <String, String>{
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri =
        Uri.parse('$baseUrl/medicines').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((j) => Medicine.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load medicines');
  }

  static Future<Medicine> createMedicine(Medicine m) async {
    final res = await http.post(
      Uri.parse('$baseUrl/medicines'),
      headers: _headers,
      body: jsonEncode({
        'name': m.name,
        'batchNumber': m.batchNumber,
        'companyName': m.companyName,
        'quantity': m.quantity,
        'expiryDate': m.expiryDate.toIso8601String(),
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return Medicine.fromJson(data);
    throw Exception(data['message'] ?? 'Failed to create medicine');
  }

  static Future<Medicine> updateMedicine(String id, Medicine m) async {
    final res = await http.put(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': m.name,
        'batchNumber': m.batchNumber,
        'companyName': m.companyName,
        'quantity': m.quantity,
        'expiryDate': m.expiryDate.toIso8601String(),
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return Medicine.fromJson(data);
    throw Exception(data['message'] ?? 'Failed to update medicine');
  }

  static Future<void> deleteMedicine(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Failed to delete medicine');
    }
  }

  // ── Suppliers ─────────────────────────────────────────────────────────────

  static Future<List<Supplier>> getSuppliers({String? search}) async {
    final params = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri =
        Uri.parse('$baseUrl/suppliers').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((j) => Supplier.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load suppliers');
  }

  static Future<Supplier> createSupplier(Supplier s) async {
    final res = await http.post(
      Uri.parse('$baseUrl/suppliers'),
      headers: _headers,
      body: jsonEncode({
        'name': s.name,
        'location': s.location,
        'phone': s.phone,
        'details': s.details,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return Supplier.fromJson(data);
    throw Exception(data['message'] ?? 'Failed to create supplier');
  }

  static Future<Supplier> updateSupplier(String id, Supplier s) async {
    final res = await http.put(
      Uri.parse('$baseUrl/suppliers/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': s.name,
        'location': s.location,
        'phone': s.phone,
        'details': s.details,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return Supplier.fromJson(data);
    throw Exception(data['message'] ?? 'Failed to update supplier');
  }

  static Future<void> deleteSupplier(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/suppliers/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Failed to delete supplier');
    }
  }
}
