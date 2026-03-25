import 'package:flutter/foundation.dart';
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
    isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getById(companyId);
      if (data != null) _company = Company.fromJson(data);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(Company c) {
    _company = c;
    notifyListeners();
  }

  Company? getCompanyById(String id) => _company?.id == id ? _company : null;
}
