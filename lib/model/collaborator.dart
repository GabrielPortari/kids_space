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
    this.birthDate,
    this.document,
    this.address,
    this.email,
    this.contact,
    this.userType,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    String? _s(dynamic v) {
      if (v == null) return null;
      return v is String ? v : v.toString();
    }

    String? parseCompanyId(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      if (v is Map) {
        if (v['id'] != null) return _s(v['id']);
        if (v['companyId'] != null) return _s(v['companyId']);
      }
      return _s(v);
    }

    String? parseUserType(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) return raw;
      if (raw is Map) {
        if (raw['name'] is String) return raw['name'] as String;
        if (raw['type'] is String) return raw['type'] as String;
        if (raw['role'] is String) return raw['role'] as String;
      }
      return _s(raw);
    }

    return Collaborator(
      id: _s(json['id']),
      createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
      updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
      companyId: parseCompanyId(json['companyId']),
      name: _s(json['name']),
      birthDate: _s(json['birthDate']),
      document: _s(json['document']),
      address: json['address'] is Map
          ? Address.fromJson(Map<String, dynamic>.from(json['address']))
          : null,
      email: _s(json['email']),
      contact: _s(json['contact']),
      userType: userTypeFromString(
        parseUserType(json['userType'] ?? json['role']),
      ),
    );
  }

  @override
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
