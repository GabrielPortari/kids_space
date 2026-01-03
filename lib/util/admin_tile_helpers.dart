enum AdminTileType {
  company,
  responsible,
  child,
  collaborator,
  reports,
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
      return('Visualize os relatórios e logs');
  }
}

String getNavigationRoute(AdminTileType type) {
  switch (type) {
    case AdminTileType.company:
      return('/company_profile_screen');
    case AdminTileType.responsible:
      return('/users');
    case AdminTileType.child:
      return('/childrens');
    case AdminTileType.collaborator:
      return('/collaborators');
    case AdminTileType.reports:
      return('/reports');
  }
}