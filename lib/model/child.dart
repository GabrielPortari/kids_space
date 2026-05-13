import 'package:kids_space/model/user_type.dart';

import 'base_model.dart';
import 'address.dart';

class Child extends BaseModel {
  final String? name;
  final List<String>? parents;
  final List<Map<String, dynamic>>? parentsSnapshot;
  final String? birthDate;
  final String? document;
  final Address? address;
  final String? email;
  final String? contact;
  final String? companyId;
  final bool? checkedIn;
  final UserType? userType;

  Child({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.parents,
    this.parentsSnapshot,
    this.birthDate,
    this.document,
    this.address,
    this.email,
    this.contact,
    this.companyId,
    this.checkedIn,
    this.userType,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json['id'] as String?,
    createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
    updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    name: json['name'] as String?,
    birthDate: (() {
      final b = json['birthDate'];
      final dt = BaseModel.tryParseTimestamp(b);
      if (dt != null) return dt.toIso8601String();
      if (b is String) return b;
      return null;
    })(),
    parents: (() {
      final p = json['parents'];
      if (p == null) return null;
      if (p is List<dynamic>) {
        if (p.isEmpty) return <String>[];
        if (p.first is String) return p.cast<String>();
        if (p.first is Map) {
          return p
              .map((e) => (e is Map ? (e['id'] as String?) : null))
              .where((s) => s != null)
              .cast<String>()
              .toList();
        }
      }
      return null;
    })(),
    parentsSnapshot: (() {
      final s = json['parentsSnapshot'];
      if (s == null) return null;
      if (s is List<dynamic>) {
        return s
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (m) => Map<String, dynamic>.from(
                m.map((k, v) => MapEntry(k.toString(), v)),
              ),
            )
            .toList();
      }
      return null;
    })(),
    document: json['document'] as String?,
    address: json['address'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['address']))
        : null,
    email: json['email'] as String?,
    contact: json['contact'] as String?,
    companyId: json['companyId'] as String?,
    checkedIn: json['checkedIn'] is bool ? json['checkedIn'] as bool : null,
    userType: userTypeFromString(
      (json['userType'] is String)
          ? json['userType'] as String?
          : (json['userType'] is Map
                ? (json['userType']['value'] as String?) ??
                      (json['userType']['name'] as String?)
                : json['role'] as String?),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'name': name,
    'birthDate': birthDate,
    'parents': parents,
    'document': document,
    'address': address?.toJson(),
    'email': email,
    'contact': contact,
    'companyId': companyId,
    'checkedIn': checkedIn,
    'userType': userTypeToString(userType),
  };

  Child copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    List<String>? parents,
    String? birthDate,
    String? document,
    Address? address,
    String? email,
    String? contact,
    String? companyId,
    bool? checkedIn,
    UserType? user,
  }) {
    return Child(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      parents: parents ?? this.parents,
      birthDate: birthDate ?? this.birthDate,
      document: document ?? this.document,
      address: address ?? this.address,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      companyId: companyId ?? this.companyId,
      checkedIn: checkedIn ?? this.checkedIn,
      userType: user ?? this.userType,
    );
  }
}
