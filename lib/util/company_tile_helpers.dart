import 'package:kids_space/model/company_tile_model.dart';

String titleForType(CompanyTileType type) {
  switch (type) {
    case CompanyTileType.company:
      return 'Empresa';
    case CompanyTileType.dashboard:
      return 'Dashboard';
    case CompanyTileType.attendances:
      return 'Attendances';
    case CompanyTileType.responsible:
      return 'Responsaveis';
    case CompanyTileType.child:
      return 'Criancas';
    case CompanyTileType.collaborator:
      return 'Colaboradores';
    case CompanyTileType.reports:
      return 'Relatorios';
  }
}

String messageForType(CompanyTileType type) {
  switch (type) {
    case CompanyTileType.company:
      return 'Gerencie as informacoes da empresa';
    case CompanyTileType.dashboard:
      return 'Acompanhe check-in, criancas ativas e presencas';
    case CompanyTileType.attendances:
      return 'Veja todas as presencas da company';
    case CompanyTileType.responsible:
      return 'Gerencie os responsaveis';
    case CompanyTileType.child:
      return 'Gerencie as criancas';
    case CompanyTileType.collaborator:
      return 'Gerencie os colaboradores';
    case CompanyTileType.reports:
      return 'Visualize os relatorios e logs';
  }
}

String getNavigationRoute(CompanyTileType type) {
  switch (type) {
    case CompanyTileType.company:
      return '/company_profile_screen';
    case CompanyTileType.dashboard:
      return '/company_dashboard_screen';
    case CompanyTileType.attendances:
      return '/company_attendances_screen';
    case CompanyTileType.responsible:
      return '/parents';
    case CompanyTileType.child:
      return '/childrens';
    case CompanyTileType.collaborator:
      return '/collaborators';
    case CompanyTileType.reports:
      return '/reports';
  }
}
