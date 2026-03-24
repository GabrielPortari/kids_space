import 'package:flutter/foundation.dart';
import '../service/attendance_service.dart';
import '../model/attendance.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  List<Attendance> _events = [];

  List<Attendance> get events => _events;

  Future<void> refreshEvents() async {
    final data = await _service.list();
    _events = data
        .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<Attendance> checkin(Map<String, dynamic> payload) async {
    final data = await _service.checkin(payload);
    final ev = Attendance.fromJson(data);
    _events.add(ev);
    notifyListeners();
    return ev;
  }

  Future<Attendance> checkout(Map<String, dynamic> payload) async {
    final data = await _service.checkout(payload);
    final ev = Attendance.fromJson(data);
    _events.add(ev);
    notifyListeners();
    return ev;
  }
}
