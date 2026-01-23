import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:kids_space/service/base_service.dart';

import '../model/child.dart';

class ChildService extends BaseService {
  
  Future<Child?> getChildById(String? childId) async {
    try {
      final response = await dio.get('/children/$childId');
      if (response.statusCode == 200 && response.data != null) {
        return Child.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      // log error for diagnostics
      dev.log('ChildService.getChildById error: $e');
      return null;
    }
  }

  Future<bool> registerChild(Child child, String? parentId) async {
    try {
      final payload = Map<String, dynamic>.from(child.toJson());
      // remove nulls and empty strings (backend validates e-mail and other fields)
      payload.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
      // backend rejects certain properties on create
      payload.remove('id');
      payload.remove('createdAt');
      payload.remove('updatedAt');
      payload.remove('userType');
      payload.remove('companyId');
      payload.remove('responsibleUserIds');

      // If no address fields were provided, signal backend to inherit address
      final addressKeys = ['address', 'addressNumber', 'addressComplement', 'neighborhood', 'city', 'state', 'zipCode'];
      final hasAddress = addressKeys.any((k) => payload.containsKey(k));
      if (!hasAddress) payload['inheritAddress'] = true;

      dev.log('ChildService.addChild payload: $payload');
      // If parentId is expected as part of the route, send to /users/{parentId}/child
      final response = await dio.post('/users/$parentId/child', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('ChildService.addChild DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('ChildService.addChild error: $e');
      return false;
    }
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
      payload.remove('checkedIn');
      payload.remove('responsibleUserIds');

      final response = await dio.put('/children/$id', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('ChildService.updateChild DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('ChildService.updateChild error: $e');
      return false;
    }
  }

  Future<bool> deleteChild(String childId) async {
    try {
      if (childId.isEmpty) return false;
      final response = await dio.delete('/children/$childId');
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } on DioException catch (e) {
      dev.log('ChildService.deleteChild DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('ChildService.deleteChild error: $e');
      return false;
    }
  }

  Future<List<Child>> getChildrenByCompanyId(String companyId, {String? token}) async {
    try {
      final opts = token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null;
      final response = await dio.get('/children/company/$companyId', options: opts);

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
    } catch (e) {
      dev.log('ChildService.getChildrenByCompanyId error: $e');
      return [];
    }
  }
}
