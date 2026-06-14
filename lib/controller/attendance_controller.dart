import 'package:flutter/foundation.dart';
import '../service/attendance_service.dart';
import '../model/attendance.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  List<Attendance> _events = [];

  // Active checkins for current company
  List<Attendance> activeCheckins = [];
  // Last 10 events (logs)
  List<Attendance> logEvents = [];
  // Full list for company history screen
  List<Attendance> companyEvents = [];

  Attendance? lastCheckIn;
  Attendance? lastCheckOut;

  bool isLoadingActiveCheckins = false;
  bool isLoadingLogs = false;
  bool isLoadingLastCheck = false;
  bool isLoadingCompanyEvents = false;

  List<Attendance> get events => _events;

  Future<void> refreshEvents() async {
    final data = await _service.list();
    _events = data
        .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> loadAllAttendancesForCompany(String companyId) async {
    isLoadingCompanyEvents = true;
    notifyListeners();
    try {
      final data = await _service.list(query: {'companyId': companyId});
      companyEvents = data
          .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } finally {
      isLoadingCompanyEvents = false;
      notifyListeners();
    }
  }

  Future<Attendance> checkin(Map<String, dynamic> payload) async {
    final data = await _service.checkin(payload);
    final ev = Attendance.fromJson(data);
    _events.add(ev);
    // keep active list in sync
    activeCheckins.add(ev);
    notifyListeners();
    return ev;
  }

  Future<Attendance> checkout(Map<String, dynamic> payload) async {
    final data = await _service.checkout(payload);
    final ev = Attendance.fromJson(data);
    _events.add(ev);
    // remove from active if present
    activeCheckins.removeWhere((a) => a.id == ev.id || a.childId == ev.childId);
    notifyListeners();
    return ev;
  }

  Future<void> loadActiveCheckinsForCompany(String? companyId) async {
    isLoadingActiveCheckins = true;
    notifyListeners();
    try {
      final data = await _service.getActiveCheckinsForCompany(
        companyId: companyId,
      );
      activeCheckins = data
          .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } finally {
      isLoadingActiveCheckins = false;
      notifyListeners();
    }
  }

  Future<void> loadLast10AttendancesForCompany(String? companyId) async {
    isLoadingLogs = true;
    notifyListeners();
    try {
      final data = await _service.getLast10ForCompany(companyId: companyId);
      logEvents = data
          .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } finally {
      isLoadingLogs = false;
      notifyListeners();
    }
  }

  Future<void> loadLastCheckinAndCheckoutForCompany(String? companyId) async {
    isLoadingLastCheck = true;
    notifyListeners();
    try {
      final data = await _service.getLastCheckinAndCheckoutForCompany(
        companyId: companyId,
      );
      lastCheckIn = data['lastCheckin'] != null
          ? Attendance.fromJson(Map<String, dynamic>.from(data['lastCheckin']))
          : null;
      lastCheckOut = data['lastCheckout'] != null
          ? Attendance.fromJson(Map<String, dynamic>.from(data['lastCheckout']))
          : null;
    } finally {
      isLoadingLastCheck = false;
      notifyListeners();
    }
  }
}
