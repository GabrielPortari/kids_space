import 'dart:convert';
import 'api_client.dart';

class ParentService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/parents', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create parent: ${res.statusCode}');
  }

  Future<List<dynamic>> list({Map<String, String>? query}) async {
    final res = await _api.get('/v2/parents');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list parents: ${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final res = await _api.get('/v2/parents/$id');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get parent: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch('/v2/parents/$id', payload);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update parent: ${res.statusCode}');
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/v2/parents/$id');
    return res.statusCode == 204;
  }
}
