import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/check_event_controller.dart';
import 'package:kids_space/controller/activity_log_controller.dart';
import 'package:kids_space/service/activity_log_service.dart';

void setup(GetIt getIt) {
  getIt.registerSingleton<CheckEventController>(CheckEventController());

  getIt.registerSingleton<CollaboratorController>(CollaboratorController());
  getIt.registerSingleton<CompanyController>(CompanyController());
  getIt.registerSingleton<AuthController>(AuthController());
  getIt.registerSingleton<UserController>(UserController());
  getIt.registerSingleton<ChildController>(ChildController());
  getIt.registerSingleton<ActivityLogService>(ActivityLogService());  
  getIt.registerSingleton<ActivityLogController>(ActivityLogController());

}