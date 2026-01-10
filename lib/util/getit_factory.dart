import 'package:get_it/get_it.dart';
import 'package:kids_space/service/collaborator_service.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/activity_log_controller.dart';
import 'package:kids_space/service/activity_log_service.dart';

void setup(GetIt getIt) {
  // Register services first so controllers can reuse the same instances
  getIt.registerSingleton<CollaboratorService>(CollaboratorService());

  getIt.registerSingleton<AttendanceController>(AttendanceController());
  getIt.registerSingleton<CollaboratorController>(CollaboratorController());
  getIt.registerSingleton<CompanyController>(CompanyController());
  getIt.registerSingleton<AuthController>(AuthController());
  getIt.registerSingleton<UserController>(UserController());
  getIt.registerSingleton<ChildController>(ChildController());
  getIt.registerSingleton<ActivityLogService>(ActivityLogService());  
  getIt.registerSingleton<ActivityLogController>(ActivityLogController());

}