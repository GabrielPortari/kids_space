import 'base_model.dart';
import 'address.dart';
import 'user_type.dart';

class Collaborator extends BaseModel {
  final String? companyId;
  final String? name;
  final String? birthDate;
  final String? document;
  final Address? address;
  final String? email;
  final String? contact;
  final UserType? userType;

  Collaborator({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.companyId,
    this.name,
    this.document,
    this.address,
    this.email,
    this.contact,
    this.userType,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    id: json['id'] as String?,
    createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
    updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    companyId: json['companyId'] as String?,
    name: json['name'] as String?,
    birthDate: json['birthDate'] as String?,
    document: json['document'] as String?,
    address: json['address'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['address']))
        : null,
    email: json['email'] as String?,
    contact: json['contact'] as String?,
    userType: userTypeFromString(
      json['userType'] as String? ?? json['role'] as String?,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'companyId': companyId,
    'name': name,
    'birthDate': birthDate,
    'document': document,
    'address': address?.toJson(),
    'email': email,
    'contact': contact,
    'userType': userTypeToString(userType),
  };
}
