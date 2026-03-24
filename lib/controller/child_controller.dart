import 'package:flutter/foundation.dart';
import '../service/child_service.dart';
import '../model/child.dart';

class ChildController extends ChangeNotifier {
  final ChildService _service = ChildService();
  List<Child> _children = [];

  List<Child> get children => _children;

  Future<void> refreshChildren() async {
    final data = await _service.list();
    _children = data
        .map((e) => Child.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<Child> createChild(Map<String, dynamic> payload) async {
    final data = await _service.create(payload);
    final child = Child.fromJson(data);
    _children.add(child);
    notifyListeners();
    return child;
  }
}
