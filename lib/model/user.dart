import 'package:kids_space/model/child.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String companyId;
  final List<Child>? childrens; // IDs das crianças sob responsabilidade

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.companyId,
    this.childrens,
  });
}