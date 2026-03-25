import 'base_model.dart';
import 'address.dart';

class Child extends BaseModel {
  final String? name;
  final List<String>? parents;
  final String? document;
  final Address? address;
  final String? email;
  final String? contact;
  final String? companyId;
  final bool? checkedIn;

  Child({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.parents,
    this.document,
    this.address,
    this.email,
    this.contact,
    this.companyId,
    this.checkedIn,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json['id'] as String?,
    createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
    updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    name: json['name'] as String?,
    parents: (json['parents'] as List<dynamic>?)?.cast<String>(),
    document: json['document'] as String?,
    address: json['address'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['address']))
        : null,
    email: json['email'] as String?,
    contact: json['contact'] as String?,
    companyId: json['companyId'] as String?,
    checkedIn: json['checkedIn'] is bool ? json['checkedIn'] as bool : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'name': name,
    'parents': parents,
    'document': document,
    'address': address?.toJson(),
    'email': email,
    'contact': contact,
    'companyId': companyId,
    'checkedIn': checkedIn,
  };

  Child copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    List<String>? parents,
    String? document,
    Address? address,
    String? email,
    String? contact,
    String? companyId,
    bool? checkedIn,
  }) {
    return Child(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      parents: parents ?? this.parents,
      document: document ?? this.document,
      address: address ?? this.address,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      companyId: companyId ?? this.companyId,
      checkedIn: checkedIn ?? this.checkedIn,
    );
  }
}
