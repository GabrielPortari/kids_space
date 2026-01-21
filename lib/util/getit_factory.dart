
import 'package:get_it/get_it.dart';
import 'package:kids_space/service/auth_service.dart';
import 'package:kids_space/service/child_service.dart';
import 'package:kids_space/service/collaborator_service.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/service/company_service.dart';
import 'package:kids_space/service/user_service.dart';

void setup(GetIt getIt) {
  getIt.registerSingleton<CompanyService>(CompanyService());
  getIt.registerSingleton<CollaboratorService>(CollaboratorService());
  getIt.registerSingleton<ChildService>(ChildService());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<UserService>(UserService());

  // Register controllers after services; inject services via constructor
  getIt.registerSingleton<ChildController>(ChildController(getIt<ChildService>()));
  getIt.registerSingleton<UserController>(UserController(getIt<UserService>()));
  getIt.registerSingleton<AttendanceController>(AttendanceController());
  getIt.registerSingleton<CollaboratorController>(CollaboratorController());
  getIt.registerSingleton<CompanyController>(CompanyController());
  getIt.registerSingleton<AuthController>(AuthController());

}