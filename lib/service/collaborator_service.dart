import 'dart:convert';
import 'api_client.dart';

class CollaboratorService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/collaborators', payload);
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create collaborator: \\${res.statusCode}');
  }
}
