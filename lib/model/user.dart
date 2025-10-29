import 'package:kids_space/model/child.dart';

class User {
  final String id;
  final String name;
  final String companyId;
  final List<Child>? childrens; // IDs das crianças sob responsabilidade

  User({
    required this.id,
    required this.name,
    required this.companyId,
    this.childrens,
  });
}