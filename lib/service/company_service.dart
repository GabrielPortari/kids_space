import 'dart:convert';
import 'api_client.dart';

class CompanyService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getMyCompany() async {
    final res = await _api.get('/v2/companies/me');
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to get company: \\${res.statusCode}');
  }

  Future<Map<String, dynamic>> updateMyCompany(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.patch('/v2/companies/me', payload);
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update company: \\${res.statusCode}');
  }
}
