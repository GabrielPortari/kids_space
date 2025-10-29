import '../model/company.dart';
import '../service/company_service.dart';

class CompanyController {
  
  final CompanyService _companyService = CompanyService();
  
  List<Company> _companies = [];
  Company? _companySelected;

  List<Company> get companies => _companies;
  Company? get companySelected => _companySelected;

  Future<void> loadCompanies() async {
    _companies = await _companyService.getAllCompanies();
  }

  List<Company> filterCompanies(String query) {
    if (query.isEmpty) return _companies;
    return _companies
        .where((company) => company.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  void selectCompany(Company company) {
    _companySelected = company;
  }
}