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

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'child': child.toJson(),
        'collaborator': collaborator.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'checkType': checkType.toString().split('.').last,
      };

  factory CheckEvent.fromJson(Map<String, dynamic> json) => CheckEvent(
        id: json['id'] as String,
        companyId: json['companyId'] as String,
        child: Child.fromJson(json['child']),
        collaborator: Collaborator.fromJson(json['collaborator']),
        timestamp: DateTime.parse(json['timestamp'] as String),
        checkType: json['checkType'] == 'checkIn'
            ? CheckType.checkIn
            : CheckType.checkOut,
  );
}