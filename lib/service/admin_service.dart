import 'dart:convert';

import 'api_client.dart';

class AdminService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/admins', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create admin: ${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final res = await _api.get('/v2/admins/$id');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get admin: ${res.statusCode}');
  }

  Future<List<dynamic>> list({
    String? name,
    String? email,
    String? document,
    bool? active,
  }) async {
    final params = <String, String>{};
    if (name != null && name.trim().isNotEmpty) params['name'] = name.trim();
    if (email != null && email.trim().isNotEmpty) {
      params['email'] = email.trim();
    }
    if (document != null && document.trim().isNotEmpty) {
      params['document'] = document.trim();
    }
    if (active != null) params['active'] = active.toString();

    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    final path = query.isEmpty ? '/v2/admins' : '/v2/admins?$query';

    final res = await _api.get(path);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list admins: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch('/v2/admins/$id', payload);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update admin: ${res.statusCode}');
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/v2/admins/$id');
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete admin: ${res.statusCode}');
  }
}
