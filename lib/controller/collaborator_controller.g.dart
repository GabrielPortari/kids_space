// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborator_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CollaboratorController on _CollaboratorController, Store {
  Computed<List<Collaborator>>? _$filteredCollaboratorsComputed;

  @override
  List<Collaborator> get filteredCollaborators =>
      (_$filteredCollaboratorsComputed ??= Computed<List<Collaborator>>(
        () => super.filteredCollaborators,
        name: '_CollaboratorController.filteredCollaborators',
      )).value;

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

  late final _$collaboratorsAtom = Atom(
    name: '_CollaboratorController.collaborators',
    context: context,
  );

  @override
  ObservableList<Collaborator> get collaborators {
    _$collaboratorsAtom.reportRead();
    return super.collaborators;
  }

  @override
  set collaborators(ObservableList<Collaborator> value) {
    _$collaboratorsAtom.reportWrite(value, super.collaborators, () {
      super.collaborators = value;
    });
  }

  late final _$collaboratorFilterAtom = Atom(
    name: '_CollaboratorController.collaboratorFilter',
    context: context,
  );

  @override
  String get collaboratorFilter {
    _$collaboratorFilterAtom.reportRead();
    return super.collaboratorFilter;
  }

  @override
  set collaboratorFilter(String value) {
    _$collaboratorFilterAtom.reportWrite(value, super.collaboratorFilter, () {
      super.collaboratorFilter = value;
    });
  }

  late final _$refreshLoadingAtom = Atom(
    name: '_CollaboratorController.refreshLoading',
    context: context,
  );

  @override
  bool get refreshLoading {
    _$refreshLoadingAtom.reportRead();
    return super.refreshLoading;
  }

  @override
  set refreshLoading(bool value) {
    _$refreshLoadingAtom.reportWrite(value, super.refreshLoading, () {
      super.refreshLoading = value;
    });
  }

  late final _$refreshCollaboratorsForCompanyAsyncAction = AsyncAction(
    '_CollaboratorController.refreshCollaboratorsForCompany',
    context: context,
  );

  @override
  Future<void> refreshCollaboratorsForCompany(String? companyId) {
    return _$refreshCollaboratorsForCompanyAsyncAction.run(
      () => super.refreshCollaboratorsForCompany(companyId),
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
selectedCollaborator: ${selectedCollaborator},
collaborators: ${collaborators},
collaboratorFilter: ${collaboratorFilter},
refreshLoading: ${refreshLoading},
filteredCollaborators: ${filteredCollaborators}
    ''';
  }
}
