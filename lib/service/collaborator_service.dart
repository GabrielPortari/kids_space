import 'dart:convert';
import 'api_client.dart';

class CollaboratorService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/collaborators', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create collaborator: \\${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final res = await _api.get('/v2/collaborators/$id');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get collaborator: \\${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getMe() async {
    final res = await _api.get('/v2/collaborators/me');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    return null;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/v2/collaborators/$id');
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete collaborator: \\${res.statusCode}');
  }
}
