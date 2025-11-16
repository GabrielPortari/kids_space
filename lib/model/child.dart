class Child {
  final String id;
  final String name;
  final String companyId;
  final List<String> responsibleUserIds; // IDs dos responsáveis
  final bool isActive;
  final String? document; // CPF/RG ou outro identificador (opcional)

  Child({
    required this.id,
    required this.name,
    required this.companyId,
    required this.responsibleUserIds,
    this.isActive = false,
    this.document,
  });
}