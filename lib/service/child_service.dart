import 'dart:convert';
import 'api_client.dart';

class ChildService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/children', payload);
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create child: \\${res.statusCode}');
  }

  Future<List<dynamic>> list({Map<String, String>? query}) async {
    final res = await _api.get('/v2/children');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list children: \\${res.statusCode}');
  }
}
