import 'package:kids_space/model/base_model.dart';

class Child extends BaseModel{
  final String id;
  final String name;
  final String companyId;
  final List<String> responsibleUserIds;
  final bool isActive;
  final String? document; 

  Child({
    required this.id,
    required this.name,
    required this.companyId,
    required this.responsibleUserIds,
    this.isActive = false,
    this.document,
    required super.createdAt, 
    required super.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'companyId': companyId,
        'responsibleUserIds': responsibleUserIds,
        'isActive': isActive,
        'document': document,
      };

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json['id'] as String,
        name: json['name'] as String,
        companyId: json['companyId'] as String,
        responsibleUserIds:
            List<String>.from(json['responsibleUserIds'] ?? <String>[]),
        isActive: json['isActive'] == true,
        document: json['document'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}