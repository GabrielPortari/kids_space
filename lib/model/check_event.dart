class CheckEvent {
  final String id;
  final String childId;
  final String collaboratorId;
  final DateTime timestamp;
  final bool isCheckIn; // true = check-in, false = check-out
  
  CheckEvent({
    required this.id,
    required this.childId,
    required this.collaboratorId,
    required this.timestamp,
    required this.isCheckIn,
  });
}