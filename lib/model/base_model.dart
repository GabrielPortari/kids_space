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
    if (value is int) {
      // Some APIs return seconds (small int) or milliseconds (large int)
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) return DateTime.tryParse(value);
    if (value is Map) {
      // Handle Firestore timestamp maps: {_seconds: 123, _nanoseconds: 0} or {seconds:..., nanoseconds:...}
      final secs = value['_seconds'] ?? value['seconds'];
      final nanos = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
      if (secs is int) {
        final milliseconds = secs * 1000 + (nanos is int ? (nanos ~/ 1000000) : 0);
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    }
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