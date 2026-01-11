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

  late final _$selectedCollaboratorAtom = Atom(
    name: '_CollaboratorController.selectedCollaborator',
    context: context,
  );

  @override
  Collaborator? get selectedCollaborator {
    _$selectedCollaboratorAtom.reportRead();
    return super.selectedCollaborator;
  }

  @override
  set selectedCollaborator(Collaborator? value) {
    _$selectedCollaboratorAtom.reportWrite(
      value,
      super.selectedCollaborator,
      () {
        super.selectedCollaborator = value;
      },
    );
  }

  late final _$setSelectedCollaboratorAsyncAction = AsyncAction(
    '_CollaboratorController.setSelectedCollaborator',
    context: context,
  );

  @override
  Future<void> setSelectedCollaborator(Collaborator? collaborator) {
    return _$setSelectedCollaboratorAsyncAction.run(
      () => super.setSelectedCollaborator(collaborator),
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

  late final _$deleteCollaboratorAsyncAction = AsyncAction(
    '_CollaboratorController.deleteCollaborator',
    context: context,
  );

  @override
  Future<bool> deleteCollaborator(String? id) {
    return _$deleteCollaboratorAsyncAction.run(
      () => super.deleteCollaborator(id),
    );
  }

  late final _$updateCollaboratorAsyncAction = AsyncAction(
    '_CollaboratorController.updateCollaborator',
    context: context,
  );

  @override
  Future<bool> updateCollaborator(Collaborator collaborator) {
    return _$updateCollaboratorAsyncAction.run(
      () => super.updateCollaborator(collaborator),
    );
  }

  late final _$_CollaboratorControllerActionController = ActionController(
    name: '_CollaboratorController',
    context: context,
  );

  @override
  dynamic setLoggedCollaborator(Collaborator? collaborator) {
    final _$actionInfo = _$_CollaboratorControllerActionController.startAction(
      name: '_CollaboratorController.setLoggedCollaborator',
    );
    try {
      return super.setLoggedCollaborator(collaborator);
    } finally {
      _$_CollaboratorControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loggedCollaborator: ${loggedCollaborator},
selectedCollaborator: ${selectedCollaborator}
    ''';
  }
}
