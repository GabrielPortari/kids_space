import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';

class Company {
  final String id;
  final String name;
  final List<Collaborator> collaborators;
  final List<User> users;
  final List<Child> children;

  Company({
    required this.id,
    required this.name,
    required this.collaborators,
    required this.users,
    required this.children,
  });
}