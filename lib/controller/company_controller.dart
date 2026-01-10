import '../model/company.dart';
import '../service/company_service.dart';
import 'dart:developer' as developer;
import '../util/network_exceptions.dart';

class CompanyController {
  final CompanyService _companyService;

  List<Company> _companies = [];
  bool isLoading = false;
  String? error;
  Company? _companySelected;

  CompanyController({CompanyService? service}) : _companyService = service ?? CompanyService();

  List<Company> get companies => _companies;
  Company? get companySelected => _companySelected;

  /// Carrega empresas e notifica através de callbacks opcionais.
  ///
  /// - `onLoading(isLoading)` é chamado no início e no final.
  /// - `onSuccess(companies)` é chamado quando a lista foi carregada com sucesso.
  /// - `onError(message)` é chamado em caso de erro.
  Future<void> loadCompanies({
    void Function(bool isLoading)? onLoading,
    void Function(List<Company> companies)? onSuccess,
    void Function(String message)? onError,
  }) async {
    developer.log('loadCompanies start', name: 'CompanyController');
    isLoading = true;
    onLoading?.call(true);
    error = null;
    try {
      final result = await _companyService.getAllCompanies();
      _companies = result;
      developer.log('loadCompanies success count=${_companies.length}', name: 'CompanyController');
      onSuccess?.call(_companies);
    } catch (e) {
      if (e is NetworkException) {
        error = e.message;
      } else {
        error = e.toString();
      }
      developer.log('loadCompanies error: $error', name: 'CompanyController');
      onError?.call(error!);
    } finally {
      isLoading = false;
      onLoading?.call(false);
    }
  }

  List<Company> filterCompanies(String query) {
    if (query.isEmpty) return _companies;
    return _companies
        .where((company) => company.fantasyName?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
  }

  void selectCompany(Company company) {
    _companySelected = company;
  }

  Company getCompanyById(String id) {
    return _companies.firstWhere((company) => company.id == id);
  }
}