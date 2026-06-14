import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import '../service/company_service.dart';
import '../model/company.dart';

class CompanyController extends ChangeNotifier {
  final CompanyService _service = CompanyService();
  Company? _company;
  bool isLoading = false;

  Company? get company => _company;

  Future<void> loadMyCompany() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getMyCompany();
      _company = Company.fromJson(data);
      dev.log(
        'CompanyController.loadMyCompany: loaded id=${_company?.id} name=${_company?.name}',
      );
    } catch (e, st) {
      dev.log(
        'CompanyController.loadMyCompany error: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMyCompany(Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();
    try {
      final updated = await _service.updateMyCompany(payload);
      _company = Company.fromJson(updated);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompanyById(String companyId) async {
    if (companyId.isEmpty) return;
    if (_isCollaboratorRole()) {
      // Collaborator can only read company name by dedicated endpoint.
      await loadCompanyNameById(companyId);
      return;
    }
    isLoading = true;
    notifyListeners();
    dev.log('CompanyController.loadCompanyById: start companyId=$companyId');
    try {
      final data = await _service.getById(companyId);
      if (data != null) {
        _company = Company.fromJson(data);
        dev.log(
          'CompanyController.loadCompanyById: loaded company id=${_company?.id} name=${_company?.name}',
        );
      } else {
        dev.log(
          'CompanyController.loadCompanyById: no data for companyId=$companyId',
        );
      }
    } catch (e, st) {
      dev.log(
        'CompanyController.loadCompanyById error: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompanyNameById(String companyId) async {
    if (companyId.isEmpty) return;
    isLoading = true;
    notifyListeners();
    dev.log(
      'CompanyController.loadCompanyNameById: start companyId=$companyId',
    );
    try {
      final name = await _service.getNameById(companyId);
      if (name != null) {
        if (_company?.id == companyId) {
          final current = _company;
          _company = Company(
            id: current?.id,
            createdAt: current?.createdAt,
            updatedAt: current?.updatedAt,
            name: name,
            legalName: current?.legalName,
            cnpj: current?.cnpj,
            website: current?.website,
            logoUrl: current?.logoUrl,
            address: current?.address,
            contact: current?.contact,
            email: current?.email,
            verified: current?.verified,
            active: current?.active,
          );
        } else {
          _company = Company(id: companyId, name: name);
        }
        dev.log(
          'CompanyController.loadCompanyNameById: loaded companyId=$companyId name=$name',
        );
      } else {
        dev.log(
          'CompanyController.loadCompanyNameById: no data for companyId=$companyId',
        );
      }
    } catch (e, st) {
      dev.log(
        'CompanyController.loadCompanyNameById error: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(Company c) {
    _company = c;
    notifyListeners();
  }

  bool _isCollaboratorRole() {
    if (!GetIt.I.isRegistered<AuthController>()) return false;
    final auth = GetIt.I.get<AuthController>();
    return auth.role == UserRole.collaborator;
  }

  Company? getCompanyById(String id) => _company?.id == id ? _company : null;
}
