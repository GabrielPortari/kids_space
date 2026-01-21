import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/service/attendance_service.dart';
// developer logs removed; keep controller imports minimal
import 'package:mobx/mobx.dart';
import 'base_controller.dart';

part 'attendance_controller.g.dart';

class AttendanceController = _AttendanceController with _$AttendanceController;

abstract class _AttendanceController extends BaseController with Store {
  final AttendanceService _service = AttendanceService();

  Future<bool> doCheckin(Attendance attendance) async {
    final ok = await _service.doCheckin(attendance);
    if (ok) {
      final cid = attendance.companyId;
      if (cid != null && cid.isNotEmpty) {
        await loadActiveCheckinsForCompany(cid);
        await loadLast10AttendancesForCompany(cid);
        await loadLastCheckinAndCheckoutForCompany(cid);
      }
    }
    return ok;
  }

  Future<bool> doCheckout(Attendance attendance) async {
    final ok = await _service.doCheckout(attendance);
    if (ok) {
      final cid = attendance.companyId;
      if (cid != null && cid.isNotEmpty) {
        await loadActiveCheckinsForCompany(cid);
        await loadLast10AttendancesForCompany(cid);
        await loadLastCheckinAndCheckoutForCompany(cid);
      }
    }
    return ok;
  }

  @observable
  bool isLoadingEvents = false;
  @observable
  List<Attendance>? events = [];
  /// Refresh all attendances for a company and populate `events` and `activeCheckins`.
  Future<void> refreshAttendancesForCompany(String companyId) async {
    isLoadingEvents = true;
    try {
      final list = await _service.getAttendancesByCompanyId(companyId);
      events = list;
    } finally {
      isLoadingEvents = false;
    }
  }

  /// Fetch attendances between optional date range (from/to ISO strings) and populate `events`.
  @action
  Future<List<Attendance>> getAttendancesBetween(String companyId, {DateTime? from, DateTime? to}) async {
    isLoadingEvents = true;
    try {
      final fromS = from?.toIso8601String();
      final toS = to?.toIso8601String();
      final list = await _service.getAttendancesBetween(companyId, from: fromS, to: toS);
      events = list;
      return list;
    } finally {
      isLoadingEvents = false;
    }
  }


  @observable
  bool isLoadingActiveCheckins = false;
  @observable
  List<Attendance>? activeCheckins = [];

  @action
  Future<void> loadActiveCheckinsForCompany(String companyId) async {
    isLoadingActiveCheckins = true;
    try {
      final list = await _service.getActiveCheckinsByCompanyId(companyId);
      activeCheckins = list;
    } finally {
      isLoadingActiveCheckins = false;
    }
  }

  /// Load the last N attendances (default 10) and populate `logEvents`.
  @observable
  bool isLoadingLogs = false;
  @observable
  List<Attendance> logEvents = [];
  @action
  Future<void> loadLast10AttendancesForCompany(String companyId, {int limit = 10}) async {
    isLoadingLogs = true;
    try {
      final list = await _service.getLastAttendances(companyId, limit: limit);
      logEvents = list;
    } finally {
      isLoadingLogs = false;
    }
  }


  @observable
  Attendance? lastCheckIn;
  @observable
  Attendance? lastCheckOut;
  @observable
  bool isLoadingLastCheck = false;
  @action
  Future<void> loadLastCheckinAndCheckoutForCompany(String companyId) async {
    isLoadingLastCheck = true;
    try {
      final lastIn = await _service.getLastCheckin(companyId);
      final lastOut = await _service.getLastCheckout(companyId);
      lastCheckIn = lastIn;
      lastCheckOut = lastOut;
    } finally {
      isLoadingLastCheck = false;
    }
  }
}
