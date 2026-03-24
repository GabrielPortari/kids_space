import 'package:get_it/get_it.dart';
import 'package:kids_space/service/api_client.dart';
import 'package:kids_space/service/auth_service.dart';
import 'package:kids_space/service/child_service.dart';
import 'package:kids_space/service/collaborator_service.dart';
import 'package:kids_space/service/parent_service.dart';
import 'package:kids_space/service/attendance_service.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/service/company_service.dart';

void setup(GetIt getIt) {
  // Services
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<CompanyService>(CompanyService());
  getIt.registerSingleton<CollaboratorService>(CollaboratorService());
  getIt.registerSingleton<ParentService>(ParentService());
  getIt.registerSingleton<ChildService>(ChildService());
  getIt.registerSingleton<AttendanceService>(AttendanceService());

  // Controllers
  getIt.registerSingleton<AuthController>(AuthController());
  getIt.registerSingleton<CompanyController>(CompanyController());
  getIt.registerSingleton<ParentController>(ParentController());
  getIt.registerSingleton<ChildController>(ChildController());
  getIt.registerSingleton<CollaboratorController>(CollaboratorController());
  getIt.registerSingleton<AttendanceController>(AttendanceController());
}
