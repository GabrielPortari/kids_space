import '../model/company.dart';
import '../model/mock/model_mock.dart';

// Serviço de empresas
class CompanyService {
  Future<List<Company>> getAllCompanies() async {
    await Future.delayed(Duration(seconds: 1));
    return mockCompanies;
  }
}
