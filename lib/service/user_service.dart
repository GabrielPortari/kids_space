import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:kids_space/service/base_service.dart';

import '../model/user.dart';

class UserService extends BaseService {
  Future<bool> createUser(User user) async {
    try {
      final payload = Map<String, dynamic>.from(user.toJson());
      // remove nulls
      payload.removeWhere((k, v) => v == null);
      // backend rejects certain properties on update - ensure they're not sent
      payload.remove('id');
      payload.remove('createdAt');
      payload.remove('updatedAt');
      payload.remove('childrenIds');

      final response = await dio.post('/user/register', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('UserService.createUser DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e, st) {
      dev.log('UserService.createUser error: $e', stackTrace: st);
      return false;
    }
  }

  User? getUserById(String id) {
    return null;
  }

  Future<List<User>> getUsersByCompanyId(String companyId, {String? token}) async {
    try {
      final opts = token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null;
      final response = await dio.get('/user/company/$companyId', options: opts);

      if (response.statusCode != 200 && response.statusCode != 201) return [];

      final data = response.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) items = data['data'];
        else if (data['users'] is List) items = data['users'];
        else {
          // if the API returned an object representing a single user
          items = [data];
        }
      }

      final List<User> users = items.map((e) {
        if (e is User) return e;
        if (e is Map<String, dynamic>) return User.fromJson(e);
        try {
          return User.fromJson(Map<String, dynamic>.from(e));
        } catch (_) {
          return null;
        }
      }).whereType<User>().toList();

      return users;
    } on DioException catch (e) {
      dev.log('UserService.getUsersByCompanyId DioException: ${e.response?.data ?? e.message}');
      return [];
    } catch (e, st) {
      dev.log('UserService.getUsersByCompanyId error: $e', stackTrace: st);
      return [];
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      if (id.isEmpty) return false;
      final response = await dio.delete('/user/$id');
      dev.log('UserService.deleteUser status=${response.statusCode} data=${response.data}');
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } on DioException catch (e) {
      dev.log('UserService.deleteUser DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e, st) {
      dev.log('UserService.deleteUser error: $e', stackTrace: st);
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      final id = user.id;
      if (id == null || id.isEmpty) return false;

      final payload = Map<String, dynamic>.from(user.toJson());
      // remove nulls
      payload.removeWhere((k, v) => v == null);
      // backend rejects certain properties on update - ensure they're not sent
      payload.remove('id');
      payload.remove('createdAt');
      payload.remove('updatedAt');
      payload.remove('childrenIds');

      final response = await dio.put('/user/$id', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('UserService.updateUser DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e, st) {
      dev.log('UserService.updateUser error: $e', stackTrace: st);
      return false;
    }
  }
}