import 'package:uuid/uuid.dart';
import 'package:kids_space/model/activity_log.dart';
import 'package:kids_space/model/mock/model_mock.dart' as mock;

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
    if (_logs.isEmpty) {
      try {
        _logs.addAll(mock.mockActivityLogs);
      } catch (_) {}
    }
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
  }

  /// Get logs optionally filtered by date range (inclusive) and/or entity type.
  Future<List<ActivityLog>> getLogs({DateTime? from, DateTime? to, ActivityEntityType? entityType}) async {
    return _logs.where((l) {
      final ts = l.createdAt;
      if (ts == null) return false;
      if (from != null && ts.isBefore(from)) return false;
      if (to != null && ts.isAfter(to)) return false;
      if (entityType != null && l.entityType != entityType) return false;
      return true;
    }).toList();
  }

  /// Clear logs (for testing)
  Future<void> clear() async {
    _logs.clear();
  }
}
