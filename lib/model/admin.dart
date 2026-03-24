import 'base_model.dart';
import 'address.dart';

class Admin extends BaseModel {
  final String? name;
  final String? email;
  final String? document;
  final String? contact;
  final Address? address;
  final bool? active;

  Admin({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.email,
    this.document,
    this.contact,
    this.address,
    this.active,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: json['id'] as String?,
    createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
    updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    name: json['name'] as String?,
    email: json['email'] as String?,
    document: json['document'] as String?,
    contact: json['contact'] as String?,
    address: json['address'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['address']))
        : null,
    active: json['active'] as bool?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'name': name,
    'email': email,
    'document': document,
    'contact': contact,
    'address': address?.toJson(),
    'active': active,
  };
}
