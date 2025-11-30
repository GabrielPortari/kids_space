import 'package:kids_space/model/base_model.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';

class Company extends BaseModel{
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
    required super.createdAt, 
    required super.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'collaborators': collaborators?.map((e) => e.toJson()).toList(),
        'users': users?.map((e) => e.toJson()).toList(),
        'children': children?.map((e) => e.toJson()).toList(),
      };
  
  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json['id'] as String,
        name: json['name'] as String,
        logoUrl: json['logoUrl'] as String?,
        collaborators: json['collaborators'] != null
            ? (json['collaborators'] as List)
                .map((e) => Collaborator.fromJson(e))
                .toList()
            : null,
        users: json['users'] != null
            ? (json['users'] as List).map((e) => User.fromJson(e)).toList()
            : null,
        children: json['children'] != null
            ? (json['children'] as List)
                .map((e) => Child.fromJson(e))
                .toList()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}