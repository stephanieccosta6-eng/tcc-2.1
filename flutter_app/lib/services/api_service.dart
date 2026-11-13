import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Web / Desktop local: http://localhost:5000/api
  // Emulador Android: http://10.0.2.2:5000/api
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': data['error'] ?? 'Erro ao cadastrar'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Servidor indisponível. Inicie o backend (npm start) para salvar no banco de dados.'
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'user': data['user'], 'token': data['token']};
      }
      return {'success': false, 'message': data['error'] ?? 'Credenciais inválidas'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Servidor indisponível. Inicie o backend (npm start) para autenticar.'
      };
    }
  }

  static Future<Map<String, dynamic>?> fetchFridgeStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/fridge')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> updateFridgeTemperature(double temp) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/fridge/temperature'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'temperature': temp}),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  static Future<void> saveSkinQuiz({
    required String email,
    required String name,
    required String skinType,
    required String skinGoal,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/user/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'skinType': skinType,
          'skinGoal': skinGoal,
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  static Future<void> createOrder(
    String customerName,
    String customerEmail,
    List<Map<String, dynamic>> items,
    double total,
  ) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerName': customerName,
          'customerEmail': customerEmail,
          'items': items,
          'total': total,
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }
}
