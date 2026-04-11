import 'dart:convert';
import 'api_client.dart';

class ChildService {
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
    final res = await _api.post('/v2/children', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create child: ${res.statusCode}');
  }

  Future<List<dynamic>> list({Map<String, String>? query}) async {
    var path = '/v2/children';
    if (query != null && query.isNotEmpty) {
      final qs = query.entries
          .map(
            (e) =>
                '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
          )
          .join('&');
      path = '$path?$qs';
    }
    final res = await _api.get(path);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list children: ${res.statusCode}');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final res = await _api.get('/v2/children/$id');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get child: ${res.statusCode}');
  }

  Future<String?> getNameById(String childId) async {
    final res = await _api.get('/v2/children/$childId/name');
    if (res.statusCode == 200) {
      return _extractNameFromBody(res.body);
    }
    if (res.statusCode == 404) return null;
    throw Exception('Failed to get child name: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch('/v2/children/$id', payload);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update child: ${res.statusCode}');
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/v2/children/$id');
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete child: ${res.statusCode}');
  }

  /// Assign one or more parents to a child using POST /v2/children/:childId/parents
  /// Payload: { "parentIds": ["parent1", "parent2"] }
  Future<Map<String, dynamic>> assignParent(
    String childId,
    List<String> parentIds,
  ) async {
    final res = await _api.post('/v2/children/$childId/parents', {
      'parentIds': parentIds,
    });
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to assign parent(s): ${res.statusCode}');
  }
}
