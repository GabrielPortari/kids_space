// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborator_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CollaboratorController on _CollaboratorController, Store {
  late final _$loggedCollaboratorAtom = Atom(
    name: '_CollaboratorController.loggedCollaborator',
    context: context,
  );

  @override
  Collaborator? get loggedCollaborator {
    _$loggedCollaboratorAtom.reportRead();
    return super.loggedCollaborator;
  }

  @override
  set loggedCollaborator(Collaborator? value) {
    _$loggedCollaboratorAtom.reportWrite(value, super.loggedCollaborator, () {
      super.loggedCollaborator = value;
    });
  }

  late final _$setLoggedCollaboratorAsyncAction = AsyncAction(
    '_CollaboratorController.setLoggedCollaborator',
    context: context,
  );

  @override
  Future<void> setLoggedCollaborator(Collaborator? collaborator) {
    return _$setLoggedCollaboratorAsyncAction.run(
      () => super.setLoggedCollaborator(collaborator),
    );
  }

  late final _$clearLoggedCollaboratorAsyncAction = AsyncAction(
    '_CollaboratorController.clearLoggedCollaborator',
    context: context,
  );

  @override
  Future<void> clearLoggedCollaborator() {
    return _$clearLoggedCollaboratorAsyncAction.run(
      () => super.clearLoggedCollaborator(),
    );
  }

  late final _$loadLoggedCollaboratorFromPrefsAsyncAction = AsyncAction(
    '_CollaboratorController.loadLoggedCollaboratorFromPrefs',
    context: context,
  );

  @override
  Future<bool> loadLoggedCollaboratorFromPrefs() {
    return _$loadLoggedCollaboratorFromPrefsAsyncAction.run(
      () => super.loadLoggedCollaboratorFromPrefs(),
    );
  }

  @override
  String toString() {
    return '''
loggedCollaborator: ${loggedCollaborator}
    ''';
  }
}
