// Serviço de colaboradores usando Firebase Auth e Firestore
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/service/base_service.dart';

class CollaboratorService extends BaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollaboratorService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Tenta autenticar com Firebase Auth e retorna os dados do colaborador no Firestore
  Future<Collaborator?> loginCollaborator(String email, String password) async {
    developer.log('loginCollaborator called: email=$email', name: 'CollaboratorService');
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;

      if (uid != null) {
        final doc = await _firestore.collection('collaborators').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['id'] = doc.id;
          developer.log('loginCollaborator found id=${doc.id}', name: 'CollaboratorService');
          return Collaborator.fromJson(data);
        }
      }

      // fallback: try to find by email field
      final query = await _firestore.collection('collaborators').where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        developer.log('loginCollaborator found by email id=${doc.id}', name: 'CollaboratorService');
        return Collaborator.fromJson(data);
      }

      developer.log('loginCollaborator not found for email=$email', name: 'CollaboratorService');
      return null;
    } catch (e, st) {
      developer.log('loginCollaborator error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return null;
    }
  }

  Future<Collaborator?> getCollaboratorById(String id) async {
    try {
      developer.log('getCollaboratorById -> request', name: 'CollaboratorService', error: {'path': '/collaborator/$id'});
      final response = await dio.get('/collaborator/$id');
      developer.log('getCollaboratorById -> response', name: 'CollaboratorService', error: {'status': response.statusCode, 'data': response.data});
      if (response.statusCode == 200 && response.data != null) {
        developer.log(response.toString(), name: 'CollaboratorService');
        return Collaborator.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e, st) {
      developer.log('getCollaboratorById error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return null;
    }
  }

  Future<List<Collaborator>> getCollaboratorsByCompanyId(String companyId) async {
    try {
      final response = await dio.get('/collaborator/company/$companyId');
      if (response.statusCode != 200 && response.statusCode != 201) return [];
      final data = response.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) items = data['data'];
        else if (data['collaborators'] is List) items = data['collaborators'];
        else items = [data];
      }

      final List<Collaborator> list = items.map((e) {
        if (e is Collaborator) return e;
        if (e is Map<String, dynamic>) return Collaborator.fromJson(Map<String, dynamic>.from(e));
        try {
          return Collaborator.fromJson(Map<String, dynamic>.from(e));
        } catch (_) {
          return null;
        }
      }).whereType<Collaborator>().toList();
      return list;
    } on DioException catch (e) {
      developer.log('CollaboratorService.getCollaboratorsByCompanyId DioException: ${e.response?.data ?? e.message}', name: 'CollaboratorService');
      return [];
    } catch (e, st) {
      developer.log('CollaboratorService.getCollaboratorsByCompanyId error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return [];
    }
  }

  Future<bool> deleteCollaborator(String id) async {
    try {
      if (id.isEmpty) return false;
      final response = await dio.delete('/collaborator/$id');
      developer.log('deleteCollaborator status=${response.statusCode} data=${response.data}', name: 'CollaboratorService');
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } on DioException catch (e) {
      developer.log('deleteCollaborator DioException: ${e.response?.data ?? e.message}', name: 'CollaboratorService');
      return false;
    } catch (e, st) {
      developer.log('deleteCollaborator error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> updateCollaborator(Collaborator collaborator) async {
    try {
      final id = collaborator.id;
      if (id == null || id.isEmpty) return false;

      final payload = Map<String, dynamic>.from(collaborator.toJson());
      payload.removeWhere((k, v) => v == null);
      payload.remove('id');
      payload.remove('createdAt');
      payload.remove('updatedAt');
      payload.remove('companyId');

      final response = await dio.put('/collaborator/$id', data: payload);
      developer.log('updateCollaborator status=${response.statusCode} data=${response.data}', name: 'CollaboratorService');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      developer.log('updateCollaborator DioException: ${e.response?.data ?? e.message}', name: 'CollaboratorService');
      return false;
    } catch (e, st) {
      developer.log('updateCollaborator error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> createCollaborator(Collaborator collaborator) async {
    try {
      final payload = Map<String, dynamic>.from(collaborator.toJson());
      // remove nulls
      payload.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
      // backend rejects certain properties on create
      payload.remove('id');
      payload.remove('createdAt');
      payload.remove('updatedAt');
      payload.remove('userType');
      payload.remove('companyId');

      developer.log('createCollaborator payload=$payload', name: 'CollaboratorService');
      
      final response = await dio.post('/collaborator', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      developer.log('CollaboratorService.createCollaborator DioException: ${e.response?.data ?? e.message}', name: 'CollaboratorService');
      return false;
    } catch (e, st) {
      developer.log('CollaboratorService.createCollaborator error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return false;
    }
  }
}