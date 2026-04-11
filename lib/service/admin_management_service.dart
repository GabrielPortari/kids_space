import 'dart:convert';

import 'api_client.dart';

class AdminManagementService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getCompanyOverview(String companyId) async {
    final res = await _api.get(
      '/v2/admin-management/companies/$companyId/overview',
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load company overview: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createCollaborator(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post(
      '/v2/admin-management/companies/$companyId/collaborators',
      payload,
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create collaborator: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> updateCollaborator(
    String companyId,
    String collaboratorId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch(
      '/v2/admin-management/companies/$companyId/collaborators/$collaboratorId',
      payload,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update collaborator: ${res.statusCode}');
  }

  Future<bool> deleteCollaborator(
    String companyId,
    String collaboratorId,
  ) async {
    final res = await _api.delete(
      '/v2/admin-management/companies/$companyId/collaborators/$collaboratorId',
    );
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete collaborator: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createParent(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post(
      '/v2/admin-management/companies/$companyId/parents',
      payload,
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create parent: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> updateParent(
    String companyId,
    String parentId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch(
      '/v2/admin-management/companies/$companyId/parents/$parentId',
      payload,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update parent: ${res.statusCode}');
  }

  Future<bool> deleteParent(String companyId, String parentId) async {
    final res = await _api.delete(
      '/v2/admin-management/companies/$companyId/parents/$parentId',
    );
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete parent: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createChild(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post(
      '/v2/admin-management/companies/$companyId/children',
      payload,
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create child: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> updateChild(
    String companyId,
    String childId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch(
      '/v2/admin-management/companies/$companyId/children/$childId',
      payload,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update child: ${res.statusCode}');
  }

  Future<bool> deleteChild(String companyId, String childId) async {
    final res = await _api.delete(
      '/v2/admin-management/companies/$companyId/children/$childId',
    );
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete child: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createAttendanceCheckin(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post(
      '/v2/admin-management/companies/$companyId/attendances/checkin',
      payload,
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create attendance: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> updateAttendance(
    String companyId,
    String attendanceId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch(
      '/v2/admin-management/companies/$companyId/attendances/$attendanceId',
      payload,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update attendance: ${res.statusCode}');
  }

  Future<bool> deleteAttendance(String companyId, String attendanceId) async {
    final res = await _api.delete(
      '/v2/admin-management/companies/$companyId/attendances/$attendanceId',
    );
    if (res.statusCode == 204) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete attendance: ${res.statusCode}');
  }

  Future<List<dynamic>> listAllCollaborators() async {
    final res = await _api.get('/v2/admin-management/all/collaborators');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list collaborators: ${res.statusCode}');
  }

  Future<List<dynamic>> listAllParents() async {
    final res = await _api.get('/v2/admin-management/all/parents');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list parents: ${res.statusCode}');
  }

  Future<List<dynamic>> listAllChildren() async {
    final res = await _api.get('/v2/admin-management/all/children');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list children: ${res.statusCode}');
  }

  Future<List<dynamic>> listAllAttendances() async {
    final res = await _api.get('/v2/admin-management/all/attendances');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list attendances: ${res.statusCode}');
  }
}
