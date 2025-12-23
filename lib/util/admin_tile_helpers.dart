enum AdminTileType {
  company,
  responsible,
  child,
  collaborator,
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
  }
}

String getNavigationRoute(AdminTileType type) {
  switch (type) {
    case AdminTileType.company:
      return('/admin_company_screen');
    case AdminTileType.responsible:
      return('/users');
    case AdminTileType.child:
      return('/childrens');
    case AdminTileType.collaborator:
      return('/collaborators');
  }
}