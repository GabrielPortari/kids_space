class BaseModel {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseModel({required this.id, required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static DateTime? tryParseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static BaseModel? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final created = tryParseTimestamp(json['createdAt']);
    final updated = tryParseTimestamp(json['updatedAt']);
    return BaseModel(
      id: json['id'] as String?,
      createdAt: created,
      updatedAt: updated ?? created,
    );
  }
}