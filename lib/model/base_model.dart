class BaseModel {
  final DateTime createdAt;
  final DateTime updatedAt;

  const BaseModel({required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toJsonTimestamps() => {
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static DateTime? tryParseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static BaseModel? fromJsonTimestamps(Map<String, dynamic>? json) {
    if (json == null) return null;
    final created = tryParseTimestamp(json['createdAt']);
    final updated = tryParseTimestamp(json['updatedAt']);
    if (created == null && updated == null) return null;
    return BaseModel(
      createdAt: created ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updated ?? created ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}