import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/service/base_service.dart';

class AttendanceService extends BaseService{

  /// Performs checkin. Uses ApiClient interceptor to add Authorization header.
  Future<bool> doCheckin(Attendance attendance) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(attendance.toJson());
      // Remove null fields so backend schema validators don't see forbidden properties
      data.removeWhere((k, v) => v == null);
      dev.log('AttendanceService.doCheckin sending=${data}', name: 'AttendanceService');
      final response = await dio.post('/attendance/checkin', data: data);
      dev.log('AttendanceService.doCheckin status=${response.statusCode} data=${response.data}', name: 'AttendanceService');
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } on DioException catch (e) {
      dev.log('AttendanceService.doCheckin DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}', name: 'AttendanceService');
      return false;
    } catch (e, st) {
      dev.log('AttendanceService.doCheckin error: $e', name: 'AttendanceService', error: st);
      return false;
    }
  }

  /// Performs checkout. Endpoint fixed to singular 'attendance'.
  Future<bool> doCheckout(Attendance attendance) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(attendance.toJson());
      // Remove null fields before sending
      data.removeWhere((k, v) => v == null);
      dev.log('AttendanceService.doCheckout sending=${data}', name: 'AttendanceService');
      final response = await dio.post('/attendance/checkout', data: data);
      dev.log('AttendanceService.doCheckout status=${response.statusCode} data=${response.data}', name: 'AttendanceService');
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } on DioException catch (e) {
      dev.log('AttendanceService.doCheckout DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}', name: 'AttendanceService');
      return false;
    } catch (e, st) {
      dev.log('AttendanceService.doCheckout error: $e', name: 'AttendanceService', error: st);
      return false;
    }
  }
}
