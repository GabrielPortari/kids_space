// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserController on _UserController, Store {
  Computed<User?>? _$selectedUserComputed;

  @override
  User? get selectedUser => (_$selectedUserComputed ??= Computed<User?>(
    () => super.selectedUser,
    name: '_UserController.selectedUser',
  )).value;

  late final _$selectedUserIdAtom = Atom(
    name: '_UserController.selectedUserId',
    context: context,
  );

  @override
  String? get selectedUserId {
    _$selectedUserIdAtom.reportRead();
    return super.selectedUserId;
  }

  @override
  set selectedUserId(String? value) {
    _$selectedUserIdAtom.reportWrite(value, super.selectedUserId, () {
      super.selectedUserId = value;
    });
  }

  late final _$usersAtom = Atom(
    name: '_UserController.users',
    context: context,
  );

  @override
  ObservableList<User> get users {
    _$usersAtom.reportRead();
    return super.users;
  }

  @override
  set users(ObservableList<User> value) {
    _$usersAtom.reportWrite(value, super.users, () {
      super.users = value;
    });
  }

  late final _$_UserControllerActionController = ActionController(
    name: '_UserController',
    context: context,
  );

  @override
  void refreshUsersForCompany(String? companyId) {
    final _$actionInfo = _$_UserControllerActionController.startAction(
      name: '_UserController.refreshUsersForCompany',
    );
    try {
      return super.refreshUsersForCompany(companyId);
    } finally {
      _$_UserControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addUser(User user) {
    final _$actionInfo = _$_UserControllerActionController.startAction(
      name: '_UserController.addUser',
    );
    try {
      return super.addUser(user);
    } finally {
      _$_UserControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeUserById(String id) {
    final _$actionInfo = _$_UserControllerActionController.startAction(
      name: '_UserController.removeUserById',
    );
    try {
      return super.removeUserById(id);
    } finally {
      _$_UserControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateUser(User updated) {
    final _$actionInfo = _$_UserControllerActionController.startAction(
      name: '_UserController.updateUser',
    );
    try {
      return super.updateUser(updated);
    } finally {
      _$_UserControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedUserId: ${selectedUserId},
users: ${users},
selectedUser: ${selectedUser}
    ''';
  }
}
