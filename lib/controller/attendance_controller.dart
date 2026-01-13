import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/service/attendance_service.dart';
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

}
