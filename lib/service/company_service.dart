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
      return Company.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
