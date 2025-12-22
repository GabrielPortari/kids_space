enum AdminTileType {
  company,
  responsible,
  child,
  collaborator,
  reports,
  configurations,
}

String titleForType(AdminTileType type) {
  switch (type) {
    case AdminTileType.company:
      return 'Empresa';
    case AdminTileType.responsible:
      return 'Responsáveis';
    case AdminTileType.child:
      return 'Crianças';
    case AdminTileType.collaborator:
      return 'Colaboradores';
    case AdminTileType.reports:
      return 'Relatórios';
    case AdminTileType.configurations:
      return 'Configurações';
  }
}

String messageForType(AdminTileType type) {
  switch (type) {
    case AdminTileType.company:
      return('Gerencie as informações da empresa');
    case AdminTileType.responsible:
      return('Gerencie os responsáveis');
    case AdminTileType.child:
      return('Gerencie as crianças');
    case AdminTileType.collaborator:
      return('Gerencie os collaborator');
    case AdminTileType.reports:
      return('Veja os relatórios');
    case AdminTileType.configurations:
      return('Altere as configurações');
  }
}

String getNavigationRoute(AdminTileType type) {
  switch (type) {
    case AdminTileType.company:
      return('/admin_company_screen');
    case AdminTileType.responsible:
      return('/users');
    case AdminTileType.child:
      return('/admin_child_screen');
    case AdminTileType.collaborator:
      return('/admin_collaborator_screen');
    case AdminTileType.reports:
      return('/admin_reports_screen');
    case AdminTileType.configurations:
      return('/admin_configurations_screen');
  }
}