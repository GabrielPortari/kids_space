import 'package:kids_space/model/base_model.dart';

class User extends BaseModel{
  final String id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String companyId;
  final List<String> childrenIds; 

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.companyId,
    required this.childrenIds, 
    required super.createdAt, 
    required super.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'document': document,
        'companyId': companyId,
        'childrenIds': childrenIds,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        document: json['document'] as String,
        companyId: json['companyId'] as String,
        childrenIds: List<String>.from(json['childrenIds'] ?? <String>[]),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}