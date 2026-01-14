import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:kids_space/service/base_service.dart';

import '../model/child.dart';

class ChildService extends BaseService {
  List<Child> getActiveCheckedInChildren(String companyId) {
    return [];
  }
  
  Child? getChildById(String childId) {
    return null;
  }

  Future<bool> addChild(Child child) async {
    return true;
  }

  Future<bool> updateChild(Child child) async {
    try {
      final id = child.id;
      if (id == null || id.isEmpty) return false;

      final payload = Map<String, dynamic>.from(child.toJson());
      // remove nulls
      payload.removeWhere((k, v) => v == null);
      // backend rejects certain properties on update - ensure they're not sent
      payload.remove('id');
      payload.remove('userType');
      payload.remove('companyId');
      payload.remove('createdAt');
      payload.remove('updatedAt');
      payload.remove('isActive');
      payload.remove('responsibleUserIds');

      final response = await dio.put('/child/$id', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('UserService.updateUser DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e, st) {
      dev.log('UserService.updateUser error: $e', stackTrace: st);
      return false;
    }
  }

  Future<bool> deleteChild(String childId) async {
    try {
      if (childId.isEmpty) return false;
      final response = await dio.delete('/child/$childId');
      dev.log('ChildService.deleteChild status=${response.statusCode} data=${response.data}');
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } on DioException catch (e) {
      dev.log('ChildService.deleteChild DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e, st) {
      dev.log('ChildService.deleteChild error: $e', stackTrace: st);
      return false;
    }
  }

  Future<List<Child>> getChildrenByCompanyId(String companyId, {String? token}) async {
    try {
      final opts = token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null;
      final response = await dio.get('/child/company/$companyId', options: opts);

      if (response.statusCode != 200 && response.statusCode != 201) return [];

      final data = response.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          items = data['data'];
        } else if (data['children'] is List){ 
          items = data['children'];
        } else {
          items = [data];
        }
      }

      final List<Child> children = items.map((e) {
        if (e is Child) return e;
        if (e is Map<String, dynamic>) return Child.fromJson(e);
        try {
          return Child.fromJson(Map<String, dynamic>.from(e));
        } catch (_) {
          return null;
        }
      }).whereType<Child>().toList();
      return children;
    } on DioException catch (e) {
      dev.log('ChildService.getChildrenByCompanyId DioException: ${e.response?.data ?? e.message}');
      return [];
    } catch (e, st) {
      dev.log('ChildService.getChildrenByCompanyId error: $e', stackTrace: st);
      return [];
    }
  }
}
