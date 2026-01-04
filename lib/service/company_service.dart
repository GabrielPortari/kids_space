import '../model/company.dart';
import '../model/mock/model_mock.dart';
import 'dart:developer' as developer;

// Serviço de empresas
class CompanyService {
  Future<List<Company>> getAllCompanies() async {
    developer.log('getAllCompanies called', name: 'CompanyService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('getAllCompanies returning ${mockCompanies.length} companies', name: 'CompanyService');
    return mockCompanies;
  }
}
