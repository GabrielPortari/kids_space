// Serviço de colaboradores usando Firebase Auth e Firestore
import 'dart:developer' as dev;
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
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;

      if (uid != null) {
        final doc = await _firestore.collection('collaborators').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['id'] = doc.id;
          return Collaborator.fromJson(data);
        }
      }

      // fallback: try to find by email field
      final query = await _firestore.collection('collaborators').where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Collaborator.fromJson(data);
      }
      return null;
    } catch (e) {
      dev.log('CollaboratorService.loginCollaborator error: $e');
      return null;
    }
  }

  Future<Collaborator?> getCollaboratorById(String id) async {
    try {
      final response = await dio.get('/collaborator/$id');
      if (response.statusCode == 200 && response.data != null) {
        dynamic payload = response.data;
        if (payload is Map<String, dynamic>) {
          if (payload['data'] is Map<String, dynamic>) payload = payload['data'];
          else if (payload['collaborator'] is Map<String, dynamic>) payload = payload['collaborator'];
          else if (payload['result'] is Map<String, dynamic>) payload = payload['result'];
        }

        if (payload is Map<String, dynamic>) {
          if (payload['id'] == null || (payload['id'] is String && (payload['id'] as String).isEmpty)) {
            payload['id'] = id;
            dev.log('CollaboratorService: injected id into payload', name: 'CollaboratorService');
          }
          return Collaborator.fromJson(payload);
        }

        try {
          return Collaborator.fromJson(Map<String, dynamic>.from(payload));
        } catch (e) {
          dev.log('CollaboratorService.getCollaboratorById parse error: $e');
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      dev.log('CollaboratorService.getCollaboratorById error: $e');
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
      dev.log('CollaboratorService.getCollaboratorsByCompanyId DioException: ${e.response?.data ?? e.message}');
      return [];
    } catch (e) {
      dev.log('CollaboratorService.getCollaboratorsByCompanyId error: $e');
      return [];
    }
  }

  Future<bool> deleteCollaborator(String id) async {
    try {
      if (id.isEmpty) return false;
      final response = await dio.delete('/collaborator/$id');
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } on DioException catch (e) {
      dev.log('CollaboratorService.deleteCollaborator DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('CollaboratorService.deleteCollaborator error: $e');
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
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('CollaboratorService.updateCollaborator DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('CollaboratorService.updateCollaborator error: $e');
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

      final response = await dio.post('/collaborator', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      dev.log('CollaboratorService.createCollaborator DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('CollaboratorService.createCollaborator error: $e');
      return false;
    }
  }
}