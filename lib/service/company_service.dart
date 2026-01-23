import 'dart:developer' as dev;

import '../model/company.dart';
import 'base_service.dart';

class CompanyService extends BaseService {
  
  Future<List<Company>> getAllCompanies() async {
    try{
      final response = await dio.get('/companies');
      final companiesData = response.data as List<dynamic>;
      return companiesData.map((data) => Company.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Company> getCompanyById(String id) async {
    try{
      final response = await dio.get('/companies/$id');
      if (response.statusCode == 200 && response.data != null) {
        dynamic payload = response.data;
        if (payload is Map<String, dynamic>) {
          if (payload['data'] is Map<String, dynamic>) payload = payload['data'];
          else if (payload['company'] is Map<String, dynamic>) payload = payload['company'];
          else if (payload['result'] is Map<String, dynamic>) payload = payload['result'];
        }

        if (payload is Map<String, dynamic>) {
          if (payload['id'] == null || (payload['id'] is String && (payload['id'] as String).isEmpty)) {
            payload['id'] = id;
            dev.log('CompanyService: injected id into payload', name: 'CompanyService');
          }
          return Company.fromJson(payload);
        }

        return Company.fromJson(Map<String, dynamic>.from(payload));
      }
      throw Exception('Company not found');
    } catch (e) {
      rethrow;
    }
  }
}
