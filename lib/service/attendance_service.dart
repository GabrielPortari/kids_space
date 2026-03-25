import 'dart:convert';
import 'api_client.dart';

class AttendanceService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> checkin(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/attendance/checkin', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to checkin: \\${res.statusCode}');
  }

  Future<Map<String, dynamic>> checkout(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/attendance/checkout', payload);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to checkout: \\${res.statusCode}');
  }

  Future<List<dynamic>> list({Map<String, String>? query}) async {
    final res = await _api.get('/v2/attendance');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list attendance: \\${res.statusCode}');
  }
}
