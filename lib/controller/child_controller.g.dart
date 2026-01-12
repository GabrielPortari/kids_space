// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChildController on _ChildController, Store {
  Computed<List<Child>>? _$filteredChildrenComputed;

  @override
  List<Child> get filteredChildren =>
      (_$filteredChildrenComputed ??= Computed<List<Child>>(
        () => super.filteredChildren,
        name: '_ChildController.filteredChildren',
      )).value;

  late final _$childFilterAtom = Atom(
    name: '_ChildController.childFilter',
    context: context,
  );

  @override
  String get childFilter {
    _$childFilterAtom.reportRead();
    return super.childFilter;
  }

  @override
  set childFilter(String value) {
    _$childFilterAtom.reportWrite(value, super.childFilter, () {
      super.childFilter = value;
    });
  }

  late final _$childrenAtom = Atom(
    name: '_ChildController.children',
    context: context,
  );

  @override
  ObservableList<Child> get children {
    _$childrenAtom.reportRead();
    return super.children;
  }

  @override
  set children(ObservableList<Child> value) {
    _$childrenAtom.reportWrite(value, super.children, () {
      super.children = value;
    });
  }

  late final _$refreshLoadingAtom = Atom(
    name: '_ChildController.refreshLoading',
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

  late final _$refreshChildrenForCompanyAsyncAction = AsyncAction(
    '_ChildController.refreshChildrenForCompany',
    context: context,
  );

  @override
  Future<void> refreshChildrenForCompany(String? companyId) {
    return _$refreshChildrenForCompanyAsyncAction.run(
      () => super.refreshChildrenForCompany(companyId),
    );
  }

  @override
  String toString() {
    return '''
childFilter: ${childFilter},
children: ${children},
refreshLoading: ${refreshLoading},
filteredChildren: ${filteredChildren}
    ''';
  }
}
