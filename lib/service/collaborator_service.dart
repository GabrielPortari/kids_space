import 'dart:convert';
import 'api_client.dart';

class CollaboratorService {
  final ApiClient _api = ApiClient();

  String? _extractNameFromBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is String) return decoded;
    if (decoded is Map<String, dynamic>) {
      final value = decoded['name'];
      if (value is String) return value;
    }
    return null;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/collaborators', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create collaborator: ${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final res = await _api.get('/v2/collaborators/$id');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get collaborator: ${res.statusCode}');
  }

  Future<String?> getNameById(String collaboratorId) async {
    final res = await _api.get('/v2/collaborators/$collaboratorId/name');
    if (res.statusCode == 200) {
      return _extractNameFromBody(res.body);
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get collaborator name: ${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getMe() async {
    final res = await _api.get('/v2/collaborators/me');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    return null;
  }

  Future<List<dynamic>> list({Map<String, String>? query}) async {
    final res = await _api.get('/v2/collaborators');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list collaborators: ${res.statusCode}');
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/v2/collaborators/$id');
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete collaborator: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch('/v2/collaborators/$id', payload);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update collaborator: ${res.statusCode}');
  }
}
