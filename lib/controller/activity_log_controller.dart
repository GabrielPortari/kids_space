import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/base_controller.dart';
import 'package:mobx/mobx.dart';
import 'package:kids_space/model/activity_log.dart';
import 'package:kids_space/service/activity_log_service.dart';

part 'activity_log_controller.g.dart';

class ActivityLogController = _ActivityLogController with _$ActivityLogController;

abstract class _ActivityLogController extends BaseController with Store {
  final ActivityLogService _service = GetIt.I<ActivityLogService>();


  @observable
  bool isLoading = false;

  @observable
  List<ActivityLog> logs = [];

  @action
  Future<void> loadLogs({DateTime? from, DateTime? to, ActivityEntityType? entityType}) async {
    isLoading = true;
    try {
      final res = await _service.getLogs(from: from, to: to, entityType: entityType);
      logs = res;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addLog({
    required ActivityAction action,
    required ActivityEntityType entityType,
    String? entityId,
    String? actorId,
    DateTime? entityCreatedAt,
  }) async {
    await _service.addLog(
      action: action,
      entityType: entityType,
      entityId: entityId,
      actorId: actorId,
      entityCreatedAt: entityCreatedAt,
    );
    await loadLogs();
  }

  Future<void> clear() => _service.clear();
}
