import 'base_model.dart';
import 'address.dart';

class Parent extends BaseModel {
  final String? name;
  final List<String>? children;
  final String? document;
  final Address? address;
  final String? email;
  final String? contact;
  final String? companyId;

  Parent({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.children,
    this.document,
    this.address,
    this.email,
    this.contact,
    this.companyId,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    id: json['id'] as String?,
    createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
    updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    name: json['name'] as String?,
    children: (json['children'] as List<dynamic>?)?.cast<String>(),
    document: json['document'] as String?,
    address: json['address'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['address']))
        : null,
    email: json['email'] as String?,
    contact: json['contact'] as String?,
    companyId: json['companyId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'name': name,
    'children': children,
    'document': document,
    'address': address?.toJson(),
    'email': email,
    'contact': contact,
    'companyId': companyId,
  };
}
