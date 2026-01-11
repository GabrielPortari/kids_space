// Serviço de colaboradores usando Firebase Auth e Firestore
import 'dart:developer' as developer;
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
    return [];
  }

  Future<bool> deleteCollaborator(String id) async {
    return false;
  }

  Future<bool> updateCollaborator(Collaborator collaborator) async {
    return false;
  }
}

