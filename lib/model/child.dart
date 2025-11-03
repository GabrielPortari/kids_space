class Child {
  final String id;
  final String name;
  final String companyId;
  final List<String> responsibleUserIds; // IDs dos responsáveis
  final bool isActive;

  Child({
    required this.id,
    required this.name,
    required this.companyId,
    required this.responsibleUserIds,
    this.isActive = false,
  });
}