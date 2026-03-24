import 'package:flutter/foundation.dart';
import '../service/company_service.dart';
import '../model/company.dart';

class CompanyController extends ChangeNotifier {
  final CompanyService _service = CompanyService();
  Company? _company;

  Company? get company => _company;

  Future<void> loadMyCompany() async {
    final data = await _service.getMyCompany();
    _company = Company.fromJson(data);
    notifyListeners();
  }

  Future<void> updateMyCompany(Map<String, dynamic> payload) async {
    final updated = await _service.updateMyCompany(payload);
    _company = Company.fromJson(updated);
    notifyListeners();
  }

  void selectCompany(Company c) {
    _company = c;
    notifyListeners();
  }

  Company? getCompanyById(String id) => _company?.id == id ? _company : null;
}
