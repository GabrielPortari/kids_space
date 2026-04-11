import 'dart:convert';
import 'api_client.dart';

class AttendanceService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> checkin(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/attendance/checkin', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to checkin: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> checkout(Map<String, dynamic> payload) async {
    final res = await _api.post('/v2/attendance/checkout', payload);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to checkout: ${res.statusCode}');
  }

  Future<List<dynamic>> list({Map<String, String>? query}) async {
    String path = '/v2/attendance';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .where((e) => e.value.trim().isNotEmpty)
          .map(
            (e) =>
                '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
          )
          .join('&');
      if (queryString.isNotEmpty) {
        path = '$path?$queryString';
      }
    }

    final res = await _api.get(path);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to list attendance: ${res.statusCode}');
  }

  Future<List<dynamic>> getActiveCheckinsForCompany({String? companyId}) async {
    final path = companyId != null && companyId.isNotEmpty
        ? '/v2/attendance/company/active-checkins?companyId=$companyId'
        : '/v2/attendance/company/active-checkins';
    final res = await _api.get(path);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to get active checkins: ${res.statusCode}');
  }

  Future<List<dynamic>> getLast10ForCompany({String? companyId}) async {
    final path = companyId != null && companyId.isNotEmpty
        ? '/v2/attendance/company/last10?companyId=$companyId'
        : '/v2/attendance/company/last10';
    final res = await _api.get(path);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to get last10 attendances: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> getLastCheckinAndCheckoutForCompany({
    String? companyId,
  }) async {
    final path = companyId != null && companyId.isNotEmpty
        ? '/v2/attendance/company/last-checkin-and-checkout?companyId=$companyId'
        : '/v2/attendance/company/last-checkin-and-checkout';
    final res = await _api.get(path);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to get last checkin/checkout: ${res.statusCode}');
  }
}
