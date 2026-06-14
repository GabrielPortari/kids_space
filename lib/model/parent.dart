import 'base_model.dart';
import 'address.dart';
import 'user_type.dart';

class Parent extends BaseModel {
  final String? name;
  final List<String>? children;
  final List<Map<String, dynamic>>? childrenSnapshot;
  final String? birthDate;
  final String? document;
  final Address? address;
  final String? email;
  final String? contact;
  final String? companyId;
  final UserType? userType;

  Parent({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.name,
    this.children,
    this.childrenSnapshot,
    this.birthDate,
    this.document,
    this.address,
    this.email,
    this.contact,
    this.companyId,
    this.userType,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
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
    children: (() {
      final c = json['children'];
      if (c == null) return null;
      if (c is List<dynamic>) {
        if (c.isEmpty) return <String>[];
        if (c.first is String) return c.cast<String>();
        if (c.first is Map) {
          return c
              .map((e) => (e is Map ? (e['id'] as String?) : null))
              .where((s) => s != null)
              .cast<String>()
              .toList();
        }
      }
      return null;
    })(),
    childrenSnapshot: (() {
      final s = json['childrenSnapshot'];
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
    'children': children,
    'birthDate': birthDate,
    'document': document,
    'address': address?.toJson(),
    'email': email,
    'contact': contact,
    'companyId': companyId,
    'userType': userTypeToString(userType),
  };
}
