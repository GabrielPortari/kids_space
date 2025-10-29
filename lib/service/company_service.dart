import '../model/company.dart';

// Serviço de empresas
class CompanyService {
  // Lista estática de empresas para simulação
  static final List<Company> _companies = [
    Company(id: '1', name: 'Tech Kids'),
    Company(id: '2', name: 'EducaPlay'),
    Company(id: '3', name: 'Brincar & Aprender'),
    Company(id: '4', name: 'Mundo Infantil'),
    Company(id: '5', name: 'Kids Solutions'),
    Company(id: '6', name: 'Espaço Criança'),
    Company(id: '7', name: 'Aprender Brincando'),
    Company(id: '8', name: 'Crescer Feliz'),
    Company(id: '9', name: 'Pequenos Gênios'),
    Company(id: '10', name: 'Play School'),
  ];

  Future<List<Company>> getAllCompanies() async {
    await Future.delayed(Duration(seconds: 1));
    return _companies;
  }
}
