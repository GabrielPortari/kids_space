import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/service/attendance_service.dart';
// developer logs removed; keep controller imports minimal
import 'package:mobx/mobx.dart';
import 'base_controller.dart';

part 'attendance_controller.g.dart';

class AttendanceController = _AttendanceController with _$AttendanceController;

abstract class _AttendanceController extends BaseController with Store {
  final AttendanceService _service = AttendanceService();

  @observable
  bool isLoadingEvents = false;

  @observable
  bool isLoadingActiveCheckins = false;

  @observable
  bool isLoadingLastCheck = false;

  @observable
  bool isLoadingLog = false;

  @computed
  bool get allLoaded => !isLoadingEvents && !isLoadingActiveCheckins && !isLoadingLastCheck && !isLoadingLog;
  
  @observable
  List<Attendance>? events = [];

  @observable
  List<Attendance>? activeCheckins = [];

  @observable
  Attendance? lastCheckIn;

  @observable
  Attendance? lastCheckOut;

  @observable
  List<Attendance> logEvents = [];


  Future<bool> doCheckin(Attendance attendance) async {
    return await _service.doCheckin(attendance);
  }

  Future<bool> doCheckout(Attendance attendance) async {
    return await _service.doCheckout(attendance);
  }

  /// Refresh all attendances for a company and populate `events` and `activeCheckins`.
  Future<void> refreshAttendancesForCompany(String companyId) async {
    isLoadingEvents = true;
    try {
      final list = await _service.getAttendancesByCompany(companyId);
      events = list;
      // Active checkins are checkin records without a checkout time.
      activeCheckins = list.where((a) => a.checkoutTime == null).toList();
      // Build log events: for each attendance with checkout produce two events (checkin and checkout),
      // otherwise produce only checkin event. Then sort chronologically and keep the last 30.
      final built = <Attendance>[];
      for (final a in list) {
        if (a.checkinTime != null) {
          built.add(Attendance(
            id: a.id,
            createdAt: a.createdAt,
            updatedAt: a.updatedAt,
            attendanceType: AttendanceType.checkin,
            notes: a.notes,
            companyId: a.companyId,
            collaboratorCheckedInId: a.collaboratorCheckedInId,
            collaboratorCheckedOutId: a.collaboratorCheckedOutId,
            responsibleId: a.responsibleId,
            childId: a.childId,
            checkinTime: a.checkinTime,
            checkoutTime: null,
          ));
        }
        if (a.checkoutTime != null) {
          built.add(Attendance(
            id: a.id,
            createdAt: a.createdAt,
            updatedAt: a.updatedAt,
            attendanceType: AttendanceType.checkout,
            notes: a.notes,
            companyId: a.companyId,
            collaboratorCheckedInId: a.collaboratorCheckedInId,
            collaboratorCheckedOutId: a.collaboratorCheckedOutId,
            responsibleId: a.responsibleId,
            childId: a.childId,
            checkinTime: null,
            checkoutTime: a.checkoutTime,
          ));
        }
      }

      // Sort by event time (checkinTime or checkoutTime)
      built.sort((x, y) {
        final tx = x.checkinTime ?? x.checkoutTime;
        final ty = y.checkinTime ?? y.checkoutTime;
        if (tx == null && ty == null) return 0;
        if (tx == null) return -1;
        if (ty == null) return 1;
        return tx.compareTo(ty);
      });

      // Keep only the last 30 events (most recent)
      if (built.length <= 30) {
        logEvents = built.reversed.toList();
      } else {
        final slice = built.sublist(built.length - 30);
        logEvents = slice.reversed.toList();
      }

      // No debug logs here; only service call/response logs are kept in services.
    } finally {
      isLoadingEvents = false;
    }
  }

  /// Load last checkin and checkout for given companyId
  Future<void> loadLastChecksForCompany(String companyId) async {
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
