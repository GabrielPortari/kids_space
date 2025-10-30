import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';

enum CheckType {
  checkIn,
  checkOut,
}

class CheckEvent {
  final String id;
  final String companyId;
  final Child child;
  final Collaborator collaborator;
  final DateTime timestamp;
  final CheckType checkType;
  
  CheckEvent({
    required this.id,
    required this.companyId,
    required this.child,
    required this.collaborator,
    required this.timestamp,
    required this.checkType,
  });
}