import 'package:get_it/get_it.dart';

import '../model/company.dart';
import '../service/company_service.dart';
import 'dart:developer' as developer;
import '../util/network_exceptions.dart';
import 'base_controller.dart';

class CompanyController extends BaseController {
  final CompanyService _companyService = GetIt.I<CompanyService>();

  List<Company> _companies = [];
  bool isLoading = false;
  String? error;
  Company? _companySelected;

  List<Company> get companies => _companies;
  Company? get companySelected => _companySelected;

  Future<void> loadCompanies({
    void Function(bool isLoading)? onLoading,
    void Function(List<Company> companies)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final result = await _companyService.getAllCompanies();
      _companies = result;
      onSuccess?.call(_companies);
    } catch (e) {
      if (e is NetworkException) {
        error = e.message;
      } else {
        error = e.toString();
      }
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

  Company? getCompanyById(String id) {
    return _companies.firstWhere((company) => company.id == id);
  }
}