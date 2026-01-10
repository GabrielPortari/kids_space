import 'package:uuid/uuid.dart';
import 'package:kids_space/model/activity_log.dart';
import 'dart:developer' as developer;

/// Simple in-memory activity log service. Can be replaced later with
/// persistent storage (file, DB or API).
class ActivityLogService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  
  ActivityLogService._internal() {
    _seedFromMocks();
  }

  // Seed with mock logs if available so UI that depends on in-memory
  // service can show example data during development.
  void _seedFromMocks() {

  }

  final List<ActivityLog> _logs = [];
  final _uuid = const Uuid();

  Future<void> addLog({
    required ActivityAction action,
    required ActivityEntityType entityType,
    String? entityId,
    String? actorId,
    DateTime? entityCreatedAt,
  }) async {
    developer.log('addLog called: action=$action entityType=$entityType entityId=$entityId actorId=$actorId', name: 'ActivityLogService');
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final log = ActivityLog(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      action: action,
      entityType: entityType,
      entityId: entityId,
      actorId: actorId,
      entityCreatedAt: entityCreatedAt,
    );
    _logs.insert(0, log);
    developer.log('addLog inserted: id=${log.id}', name: 'ActivityLogService');
  }

  /// Get logs optionally filtered by date range (inclusive) and/or entity type.
  Future<List<ActivityLog>> getLogs({DateTime? from, DateTime? to, ActivityEntityType? entityType}) async {
    developer.log('getLogs called: from=$from to=$to entityType=$entityType', name: 'ActivityLogService');
    final result = _logs.where((l) {
      final ts = l.createdAt;
      if (ts == null) return false;
      if (from != null && ts.isBefore(from)) return false;
      if (to != null && ts.isAfter(to)) return false;
      if (entityType != null && l.entityType != entityType) return false;
      return true;
    }).toList();
    developer.log('getLogs returning ${result.length} entries', name: 'ActivityLogService');
    return result;
  }

  /// Clear logs (for testing)
  Future<void> clear() async {
    developer.log('clear called: clearing ${_logs.length} logs', name: 'ActivityLogService');
    await Future.delayed(const Duration(milliseconds: 300));
    _logs.clear();
    developer.log('clear completed', name: 'ActivityLogService');
  }
}
