import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';

class Company {
  final String id;
  final String name;
  final String? logoUrl;
  final List<Collaborator>? collaborators;
  final List<User>? users;
  final List<Child>? children;

  Company({
    required this.id,
    required this.name,
    this.logoUrl,
    this.collaborators,
    this.users,
    this.children,
  });
}