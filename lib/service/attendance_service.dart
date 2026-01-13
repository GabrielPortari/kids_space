import 'dart:developer' as dev;
import 'dart:convert' as convert;

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

  /// Fetch last checkin for a given companyId (passed as path param).
  Future<Attendance?> getLastCheckin(String companyId) async {
    try {
      final response = await dio.get('/attendance/company/$companyId/last-checkin');
      dev.log('AttendanceService.getLastCheckin status=${response.statusCode} data=${response.data}', name: 'AttendanceService');
      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;
        Map<String, dynamic>? dataMap;
        if (raw is Map) {
          dataMap = Map<String, dynamic>.from(raw as Map);
        } else if (raw is String) {
          final trimmed = raw.trim();
          if (trimmed.isNotEmpty) {
            try {
              final decoded = convert.json.decode(trimmed);
              if (decoded is Map) dataMap = Map<String, dynamic>.from(decoded as Map);
            } catch (e) {
              dev.log('AttendanceService.getLastCheckin: failed to json-decode string response', name: 'AttendanceService', error: e);
            }
          } else {
            dev.log('AttendanceService.getLastCheckin: empty string response, skipping decode', name: 'AttendanceService');
          }
        }

        if (dataMap != null) {
          return Attendance.fromJson(dataMap);
        }
      }
      return null;
    } on DioException catch (e) {
      dev.log('AttendanceService.getLastCheckin DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}', name: 'AttendanceService');
      return null;
    } catch (e, st) {
      dev.log('AttendanceService.getLastCheckin error: $e', name: 'AttendanceService', error: st);
      return null;
    }
  }

  /// Fetch last checkout for a given companyId (passed as path param).
  Future<Attendance?> getLastCheckout(String companyId) async {
    try {
      final response = await dio.get('/attendance/company/$companyId/last-checkout');
      dev.log('AttendanceService.getLastCheckout status=${response.statusCode} data=${response.data}', name: 'AttendanceService');
      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;
        Map<String, dynamic>? dataMap;
        if (raw is Map) {
          dataMap = Map<String, dynamic>.from(raw as Map);
        } else if (raw is String) {
          final trimmed = raw.trim();
          if (trimmed.isNotEmpty) {
            try {
              final decoded = convert.json.decode(trimmed);
              if (decoded is Map) dataMap = Map<String, dynamic>.from(decoded as Map);
            } catch (e) {
              dev.log('AttendanceService.getLastCheckout: failed to json-decode string response', name: 'AttendanceService', error: e);
            }
          } else {
            dev.log('AttendanceService.getLastCheckout: empty string response, skipping decode', name: 'AttendanceService');
          }
        }

        if (dataMap != null) {
          return Attendance.fromJson(dataMap);
        }
      }
      return null;
    } on DioException catch (e) {
      dev.log('AttendanceService.getLastCheckout DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}', name: 'AttendanceService');
      return null;
    } catch (e, st) {
      dev.log('AttendanceService.getLastCheckout error: $e', name: 'AttendanceService', error: st);
      return null;
    }
  }

  /// Fetch attendances list for a given companyId
  Future<List<Attendance>> getAttendancesByCompany(String companyId) async {
    try {
      final response = await dio.get('/attendance/company/$companyId');
      dev.log('AttendanceService.getAttendancesByCompany status=${response.statusCode} data=${response.data}', name: 'AttendanceService');
      if (response.statusCode == 200 && response.data != null) {
        final List<Map<String, dynamic>> items = [];
        final raw = response.data;

        if (raw is List) {
          for (final e in raw) {
            if (e is Map) items.add(Map<String, dynamic>.from(e));
            else if (e is String) {
              final trimmed = e.trim();
              if (trimmed.isNotEmpty) {
                try {
                  final decoded = convert.json.decode(trimmed);
                  if (decoded is Map) items.add(Map<String, dynamic>.from(decoded as Map));
                } catch (_) {}
              }
            }
          }
        } else if (raw is String) {
          final trimmed = raw.trim();
          if (trimmed.isNotEmpty) {
            try {
              final decoded = convert.json.decode(trimmed);
              if (decoded is List) {
                for (final e in decoded) {
                  if (e is Map) items.add(Map<String, dynamic>.from(e));
                }
              } else if (decoded is Map) {
                items.add(Map<String, dynamic>.from(decoded));
              }
            } catch (e) {
              dev.log('AttendanceService.getAttendancesByCompany: failed to decode string response', name: 'AttendanceService', error: e);
            }
          }
        } else if (raw is Map) {
          // API might return a single object or a wrapper containing an array
          final mapRaw = Map<String, dynamic>.from(raw);
          if (mapRaw.containsKey('items') && mapRaw['items'] is List) {
            for (final e in mapRaw['items']) {
              if (e is Map) items.add(Map<String, dynamic>.from(e));
            }
          } else if (mapRaw.containsKey('data') && mapRaw['data'] is List) {
            for (final e in mapRaw['data']) {
              if (e is Map) items.add(Map<String, dynamic>.from(e));
            }
          } else {
            items.add(mapRaw);
          }
        }

        // Debug: log raw timestamp values and their runtime types for investigation
        try {
          dev.log('AttendanceService.getAttendancesByCompany: raw response type=${raw.runtimeType}', name: 'AttendanceService');
          // Log full first 3 items so we can inspect field names and nested structures
          for (var i = 0; i < items.length && i < 3; i++) {
            final it = items[i];
            dev.log('AttendanceService.getAttendancesByCompany: item[$i] raw=${convert.json.encode(it)}', name: 'AttendanceService');
          }
        } catch (e, st) {
          dev.log('AttendanceService.getAttendancesByCompany: debug log failed: $e', name: 'AttendanceService', error: st);
        }

        return items.map((m) => Attendance.fromJson(m)).toList();
      }
      return [];
    } on DioException catch (e) {
      dev.log('AttendanceService.getAttendancesByCompany DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}', name: 'AttendanceService');
      return [];
    } catch (e, st) {
      dev.log('AttendanceService.getAttendancesByCompany error: $e', name: 'AttendanceService', error: st);
      return [];
    }
  }

  
}
