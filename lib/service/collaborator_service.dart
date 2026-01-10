// Serviço de colaboradores usando Firebase Auth e Firestore
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kids_space/model/collaborator.dart';

class CollaboratorService {
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

  Future<Collaborator?> getCollaboratorByEmail(String email) async {
    developer.log('getCollaboratorByEmail called: email=$email', name: 'CollaboratorService');
    try {
      final query = await _firestore.collection('collaborators').where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isEmpty) {
        developer.log('getCollaboratorByEmail not found: email=$email', name: 'CollaboratorService');
        return null;
      }
      final doc = query.docs.first;
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      developer.log('getCollaboratorByEmail found id=${doc.id}', name: 'CollaboratorService');
      return Collaborator.fromJson(data);
    } catch (e, st) {
      developer.log('getCollaboratorByEmail error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return null;
    }
  }

  Future<Collaborator?> getCollaboratorById(String id) async {
    developer.log('getCollaboratorById called: id=$id', name: 'CollaboratorService');
    try {
      final doc = await _firestore.collection('collaborators').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        developer.log('getCollaboratorById not found: id=$id', name: 'CollaboratorService');
        return null;
      }
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      developer.log('getCollaboratorById found id=${doc.id}', name: 'CollaboratorService');
      return Collaborator.fromJson(data);
    } catch (e, st) {
      developer.log('getCollaboratorById error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return null;
    }
  }

  Future<List<Collaborator>> getCollaboratorsByCompanyId(String companyId) async {
    developer.log('getCollaboratorsByCompanyId called: companyId=$companyId', name: 'CollaboratorService');
    try {
      final query = await _firestore.collection('collaborators').where('companyId', isEqualTo: companyId).get();
      final result = query.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        return Collaborator.fromJson(data);
      }).toList();
      developer.log('getCollaboratorsByCompanyId returning ${result.length} collaborators for companyId=$companyId', name: 'CollaboratorService');
      return result;
    } catch (e, st) {
      developer.log('getCollaboratorsByCompanyId error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return <Collaborator>[];
    }
  }

  Future<bool> deleteCollaborator(String id) async {
    developer.log('deleteCollaborator called: id=$id', name: 'CollaboratorService');
    try {
      await _firestore.collection('collaborators').doc(id).delete();
      developer.log('deleteCollaborator success for id=$id', name: 'CollaboratorService');
      return true;
    } catch (e, st) {
      developer.log('deleteCollaborator error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return false;
    }
  }

  /// Atualiza um colaborador no Firestore (remove senha antes de salvar)
  Future<bool> updateCollaborator(Collaborator collaborator) async {
    developer.log('updateCollaborator called: id=${collaborator.id}', name: 'CollaboratorService');
    try {
      final id = collaborator.id;
      if (id == null || id.isEmpty) return false;
      final json = collaborator.toJson();
      json.remove('password');
      await _firestore.collection('collaborators').doc(id).set(json, SetOptions(merge: true));
      developer.log('updateCollaborator success for id=$id', name: 'CollaboratorService');
      return true;
    } catch (e, st) {
      developer.log('updateCollaborator error: $e', name: 'CollaboratorService', error: e, stackTrace: st);
      return false;
    }
  }
}
