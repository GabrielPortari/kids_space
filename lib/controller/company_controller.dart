import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

import '../model/company.dart';
import '../service/company_service.dart';
import '../util/network_exceptions.dart';
import 'base_controller.dart';

part 'company_controller.g.dart';
class CompanyController = _CompanyControllerBase with _$CompanyController;
abstract class _CompanyControllerBase extends BaseController with Store {
  final CompanyService _companyService = GetIt.I<CompanyService>();

  List<Company> _companies = [];

  String? error;

  Company? _companySelected;

  List<Company> get companies => _companies;

  Company? get companySelected => _companySelected;

  @observable
  bool isLoading = false;
  Future<void> loadCompanies({
    void Function(bool isLoading)? onLoading,
    void Function(List<Company> companies)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      isLoading = true;
      onLoading?.call(true);
      final result = await _companyService.getAllCompanies();
      _companies = result;
      onSuccess?.call(_companies);
    } catch (e) {
      if (e is NetworkException) {
        error = e.message;
      } else {
        error = e.toString();
      }
      onError?.call(error ?? '');
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

  /// Synchronous lookup from cached list. Returns null if not found or id empty.
  Company? getCompanyById(String id) {
    if (id.isEmpty) return null;
    for (final c in _companies) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Fetch company from API and update cache. Returns the fetched company or null on error.
  Future<Company?> fetchCompanyById(String id) async {
    if (id.isEmpty) return null;
    try {
      final result = await _companyService.getCompanyById(id);
      // update or add to cache
      final idx = _companies.indexWhere((c) => c.id == result.id);
      if (idx >= 0) {
        _companies[idx] = result;
      } else {
        _companies.add(result);
      }
      return result;
    } catch (e) {
      if (e is NetworkException) {
        error = e.message;
      } else {
        error = e.toString();
      }
      return null;
    }
  }
}