// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ActivityLogController on _ActivityLogController, Store {
  late final _$isLoadingAtom = Atom(
    name: '_ActivityLogController.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$logsAtom = Atom(
    name: '_ActivityLogController.logs',
    context: context,
  );

  @override
  List<ActivityLog> get logs {
    _$logsAtom.reportRead();
    return super.logs;
  }

  @override
  set logs(List<ActivityLog> value) {
    _$logsAtom.reportWrite(value, super.logs, () {
      super.logs = value;
    });
  }

  late final _$loadLogsAsyncAction = AsyncAction(
    '_ActivityLogController.loadLogs',
    context: context,
  );

  @override
  Future<void> loadLogs({
    DateTime? from,
    DateTime? to,
    ActivityEntityType? entityType,
  }) {
    return _$loadLogsAsyncAction.run(
      () => super.loadLogs(from: from, to: to, entityType: entityType),
    );
  }

  late final _$addLogAsyncAction = AsyncAction(
    '_ActivityLogController.addLog',
    context: context,
  );

  @override
  Future<void> addLog({
    required ActivityAction action,
    required ActivityEntityType entityType,
    String? entityId,
    String? actorId,
    DateTime? entityCreatedAt,
  }) {
    return _$addLogAsyncAction.run(
      () => super.addLog(
        action: action,
        entityType: entityType,
        entityId: entityId,
        actorId: actorId,
        entityCreatedAt: entityCreatedAt,
      ),
    );
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
logs: ${logs}
    ''';
  }
}
