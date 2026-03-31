import 'package:kids_space/model/base_model.dart';
import 'package:kids_space/model/user_type.dart';

enum ActionType {
  CREATE,
  UPDATE,
  DELETE,
  CHECKIN,
  CHECKOUT,
  LOGIN,
  LOGOUT,
  OTHER,
}

ActionType? actionTypeFromString(String? s) {
  if (s == null) return null;
  switch (s.toUpperCase()) {
    case 'CREATE':
      return ActionType.CREATE;
    case 'UPDATE':
      return ActionType.UPDATE;
    case 'DELETE':
      return ActionType.DELETE;
    case 'CHECKIN':
      return ActionType.CHECKIN;
    case 'CHECKOUT':
      return ActionType.CHECKOUT;
    case 'LOGIN':
      return ActionType.LOGIN;
    case 'LOGOUT':
      return ActionType.LOGOUT;
    case 'OTHER':
      return ActionType.OTHER;
    default:
      return null;
  }
}

String? actionTypeToString(ActionType? t) {
  if (t == null) return null;
  return t.toString().split('.').last;
}

enum ResourceType {
  user,
  company,
  parent,
  child,
  attendance,
  collaborator,
  token,
  other,
}

ResourceType? resourceTypeFromString(String? s) {
  if (s == null) return null;
  final v = s.toLowerCase();
  switch (v) {
    case 'user':
      return ResourceType.user;
    case 'company':
      return ResourceType.company;
    case 'parent':
      return ResourceType.parent;
    case 'child':
      return ResourceType.child;
    case 'attendance':
      return ResourceType.attendance;
    case 'collaborator':
      return ResourceType.collaborator;
    case 'token':
      return ResourceType.token;
    case 'other':
      return ResourceType.other;
    default:
      return null;
  }
}

String? resourceTypeToString(ResourceType? t) {
  if (t == null) return null;
  return t.toString().split('.').last;
}

class LogEntry extends BaseModel {
  final ActionType action;
  final ResourceType resourceType;
  final String? resourceId;
  final String? actorId;
  final UserType? actorType;
  final DateTime? timestamp;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final Map<String, dynamic>? metadata;
  final String? ip;

  LogEntry({
    String? id,
    required this.action,
    required this.resourceType,
    this.resourceId,
    this.actorId,
    this.actorType,
    this.timestamp,
    this.before,
    this.after,
    this.metadata,
    this.ip,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String?,
      action:
          actionTypeFromString(json['action'] as String?) ?? ActionType.OTHER,
      resourceType:
          resourceTypeFromString(json['resourceType'] as String?) ??
          ResourceType.other,
      resourceId: json['resourceId'] as String?,
      actorId: json['actorId'] as String?,
      actorType: userTypeFromString(json['actorType'] as String?),
      timestamp:
          BaseModel.tryParseTimestamp(json['timestamp']) ??
          BaseModel.tryParseTimestamp(json['createdAt']),
      before: json['before'] is Map
          ? Map<String, dynamic>.from(json['before'])
          : null,
      after: json['after'] is Map
          ? Map<String, dynamic>.from(json['after'])
          : null,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      ip: json['ip'] as String?,
      createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
      updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': actionTypeToString(action),
    'resourceType': resourceTypeToString(resourceType),
    'resourceId': resourceId,
    'actorId': actorId,
    'actorType': userTypeToString(actorType),
    'timestamp': timestamp?.toIso8601String(),
    'before': before,
    'after': after,
    'metadata': metadata,
    'ip': ip,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

typedef Log = LogEntry;
