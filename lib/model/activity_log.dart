import 'package:kids_space/model/base_model.dart';

enum ActivityAction { created, updated, deleted }

enum ActivityEntityType { user, child, collaborator, company, other }

class ActivityLog extends BaseModel {
  final ActivityAction action;
  final ActivityEntityType entityType;
  final String? entityId;
  final String? actorId;
  final DateTime? entityCreatedAt; // createdAt value from the affected entity (BaseModel)

  ActivityLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.action,
    required this.entityType,
    this.entityId,
    this.actorId,
    this.entityCreatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['action'] = action.name;
    base['entityType'] = entityType.name;
    base['entityId'] = entityId;
    base['actorId'] = actorId;
    base['entityCreatedAt'] = entityCreatedAt?.toIso8601String();
    return base;
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final created = BaseModel.tryParseTimestamp(json['createdAt']);
    final updated = BaseModel.tryParseTimestamp(json['updatedAt']) ?? created;

    ActivityAction? action;
    final a = (json['action'] as String?)?.toLowerCase();
    if (a == 'created') action = ActivityAction.created;
    if (a == 'updated') action = ActivityAction.updated;
    if (a == 'deleted') action = ActivityAction.deleted;

    ActivityEntityType type = ActivityEntityType.other;
    final t = (json['entityType'] as String?)?.toLowerCase();
    if (t == 'user') type = ActivityEntityType.user;
    if (t == 'child') type = ActivityEntityType.child;
    if (t == 'collaborator') type = ActivityEntityType.collaborator;
    if (t == 'company') type = ActivityEntityType.company;

    return ActivityLog(
      id: json['id'] as String?,
      createdAt: created,
      updatedAt: updated,
      action: action ?? ActivityAction.updated,
      entityType: type,
      entityId: json['entityId'] as String?,
      actorId: json['actorId'] as String?,
      entityCreatedAt: BaseModel.tryParseTimestamp(json['entityCreatedAt']),
    );
  }
}
