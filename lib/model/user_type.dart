enum UserType { company, collaborator, parent, child, admin }

UserType? userTypeFromString(String? s) {
  if (s == null) return null;
  final v = s.toLowerCase();
  if (v == 'company' || v == 'owner') return UserType.company;
  if (v == 'collaborator' || v == 'staff') return UserType.collaborator;
  if (v == 'admin') return UserType.admin;
  if (v == 'user' || v == 'parent') return UserType.parent;
  if (v == 'child') return UserType.child;
  return null;
}

String? userTypeToString(UserType? t) {
  if (t == null) return null;
  switch (t) {
    case UserType.company:
      return 'company';
    case UserType.collaborator:
      return 'collaborator';
    case UserType.parent:
      return 'parent';
    case UserType.child:
      return 'child';
    case UserType.admin:
      return 'admin';
  }
}
