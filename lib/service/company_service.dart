import '../model/company.dart';
import 'dart:developer' as dev;
import 'base_service.dart';

class CompanyService extends BaseService {
  
  Future<List<Company>> getAllCompanies() async {
    try{
      final response = await dio.get('/company');
      final companiesData = response.data as List<dynamic>;
      dev.log('Fetched ${companiesData.length} companies', name: 'CompanyService');
      return companiesData.map((data) => Company.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Company> getCompanyById(String id) async {
    try{
      final response = await dio.get('/company/$id');
      dev.log('Fetched company with id: $id', name: 'CompanyService');
      return Company.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
