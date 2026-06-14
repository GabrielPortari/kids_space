import 'base_model.dart';
import 'address.dart';

class Company extends BaseModel {
  final String? name;
  final String? legalName;
  final String? cnpj;
  final String? website;
  final String? logoUrl;
  final Address? address;
  final String? contact;
  final String? email;
  final bool? verified;
  final bool? active;

  Company({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.legalName,
    this.cnpj,
    this.website,
    this.logoUrl,
    this.address,
    this.contact,
    this.email,
    this.verified,
    this.active,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final addr = json['address'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['address']))
        : null;
    return Company(
      id: json['id'] as String?,
      createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
      updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
      name: json['name'] as String? ?? json['fantasyName'] as String?,
      legalName:
          json['legalName'] as String? ?? json['corporateName'] as String?,
      cnpj: json['cnpj'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      address: addr,
      contact: json['contact'] as String? ?? json['phone'] as String?,
      email: json['email'] as String?,
      verified: json['verified'] as bool?,
      active: json['active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'name': name,
    'legalName': legalName,
    'cnpj': cnpj,
    'website': website,
    'logoUrl': logoUrl,
    'address': address?.toJson(),
    'contact': contact,
    'email': email,
    'verified': verified,
    'active': active,
  };
}
