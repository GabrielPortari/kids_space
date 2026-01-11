import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/service/attendance_service.dart';
import 'package:mobx/mobx.dart';
import 'base_controller.dart';

part 'attendance_controller.g.dart';

class AttendanceController = _AttendanceController with _$AttendanceController;

abstract class _AttendanceController extends BaseController with Store {
  final AttendanceService _service = AttendanceService();

  // Loading states
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
  
  // Data
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

}
