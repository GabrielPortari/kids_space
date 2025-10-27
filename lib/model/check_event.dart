enum CheckType {
  checkIn,
  checkOut,
}

class CheckEvent {
  final String id;
  final String childId;
  final String collaboratorId;
  final DateTime timestamp;
  final CheckType checkType;
  
  CheckEvent({
    required this.id,
    required this.childId,
    required this.collaboratorId,
    required this.timestamp,
    required this.checkType,
  });
}