class User {
  final String id;
  final String name;
  final String companyId;
  final List<String> childrenIds; // IDs das crianças sob responsabilidade

  User({
    required this.id,
    required this.name,
    required this.companyId,
    required this.childrenIds,
  });
}