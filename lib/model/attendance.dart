import 'base_model.dart';

enum AttendanceType { checkin, checkout }

class Attendance extends BaseModel {
  final AttendanceType? attendanceType;
  final String? notes;
  final String? companyId;
  final String? collaboratorWhoCheckedInId;
  final String? collaboratorWhoCheckedOutId;
  final String? parentIdWhoCheckedInId;
  final String? parentIdWhoCheckedOutId;
  final String? childId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int? timeCheckedInSeconds;
  final Map<String, dynamic>? childSnapshot;
  final Map<String, dynamic>? collaboratorCheckedInSnapshot;
  final Map<String, dynamic>? collaboratorCheckedOutSnapshot;
  final Map<String, dynamic>? responsibleCheckedInSnapshot;
  final Map<String, dynamic>? responsibleCheckedOutSnapshot;

  Attendance({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.attendanceType,
    this.notes,
    this.companyId,
    this.collaboratorWhoCheckedInId,
    this.collaboratorWhoCheckedOutId,
    this.parentIdWhoCheckedInId,
    this.parentIdWhoCheckedOutId,
    this.childId,
    this.checkInTime,
    this.checkOutTime,
    this.timeCheckedInSeconds,
    this.childSnapshot,
    this.collaboratorCheckedInSnapshot,
    this.collaboratorCheckedOutSnapshot,
    this.responsibleCheckedInSnapshot,
    this.responsibleCheckedOutSnapshot,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final created = BaseModel.tryParseTimestamp(json['createdAt']);
    final updated = BaseModel.tryParseTimestamp(json['updatedAt']) ?? created;
    final inTime = BaseModel.tryParseTimestamp(
      json['checkInTime'] ?? json['checkinTime'] ?? json['checkIn'],
    );
    final outTime = BaseModel.tryParseTimestamp(
      json['checkOutTime'] ?? json['checkoutTime'] ?? json['checkOut'],
    );
    AttendanceType? type;
    final t = json['attendanceType'];
    if (t is String) {
      if (t.toLowerCase() == 'checkin') type = AttendanceType.checkin;
      if (t.toLowerCase() == 'checkout') type = AttendanceType.checkout;
    }

    return Attendance(
      id: json['id'] as String?,
      createdAt: created,
      updatedAt: updated,
      attendanceType: type,
      notes: json['notes'] as String?,
      companyId: json['companyId'] as String?,
      collaboratorWhoCheckedInId:
          json['collaboratorWhoCheckedInId'] as String? ??
          json['collaboratorCheckedInId'] as String?,
      collaboratorWhoCheckedOutId:
          json['collaboratorWhoCheckedOutId'] as String? ??
          json['collaboratorCheckedOutId'] as String?,
      parentIdWhoCheckedInId:
          json['responsibleIdWhoCheckedInId'] as String? ??
          json['parentIdWhoCheckedInId'] as String? ??
          json['parentId'] as String?,
      parentIdWhoCheckedOutId:
          json['responsibleIdWhoCheckedOutId'] as String? ??
          json['parentIdWhoCheckedOutId'] as String?,
      childId: json['childId'] as String?,
      checkInTime: inTime,
      checkOutTime: outTime,
      timeCheckedInSeconds: json['timeCheckedInSeconds'] is int
          ? json['timeCheckedInSeconds'] as int
          : (json['timeCheckedInSeconds'] is String
                ? int.tryParse(json['timeCheckedInSeconds'])
                : null),
      childSnapshot: json['childSnapshot'] is Map
          ? Map<String, dynamic>.from(json['childSnapshot'])
          : (json['child'] is Map
                ? Map<String, dynamic>.from(json['child'])
                : null),
      collaboratorCheckedInSnapshot:
          json['collaboratorCheckedInSnapshot'] is Map
          ? Map<String, dynamic>.from(json['collaboratorCheckedInSnapshot'])
          : (json['collaboratorCheckedIn'] is Map
                ? Map<String, dynamic>.from(json['collaboratorCheckedIn'])
                : null),
      collaboratorCheckedOutSnapshot:
          json['collaboratorCheckedOutSnapshot'] is Map
          ? Map<String, dynamic>.from(json['collaboratorCheckedOutSnapshot'])
          : (json['collaboratorCheckedOut'] is Map
                ? Map<String, dynamic>.from(json['collaboratorCheckedOut'])
                : null),
      responsibleCheckedInSnapshot: json['responsibleCheckedInSnapshot'] is Map
          ? Map<String, dynamic>.from(json['responsibleCheckedInSnapshot'])
          : (json['responsibleCheckedIn'] is Map
                ? Map<String, dynamic>.from(json['responsibleCheckedIn'])
                : null),
      responsibleCheckedOutSnapshot:
          json['responsibleCheckedOutSnapshot'] is Map
          ? Map<String, dynamic>.from(json['responsibleCheckedOutSnapshot'])
          : (json['responsibleCheckedOut'] is Map
                ? Map<String, dynamic>.from(json['responsibleCheckedOut'])
                : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'attendanceType': attendanceType == null
        ? null
        : (attendanceType == AttendanceType.checkin ? 'checkin' : 'checkout'),
    'notes': notes,
    'companyId': companyId,
    'collaboratorWhoCheckedInId': collaboratorWhoCheckedInId,
    'collaboratorCheckedInId': collaboratorWhoCheckedInId,
    'collaboratorWhoCheckedOutId': collaboratorWhoCheckedOutId,
    'collaboratorCheckedOutId': collaboratorWhoCheckedOutId,
    'responsibleIdWhoCheckedInId': parentIdWhoCheckedInId,
    'parentIdWhoCheckedInId': parentIdWhoCheckedInId,
    'parentId': parentIdWhoCheckedInId,
    'responsibleIdWhoCheckedOutId': parentIdWhoCheckedOutId,
    'parentIdWhoCheckedOutId': parentIdWhoCheckedOutId,
    'childId': childId,
    'checkInTime': checkInTime?.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'timeCheckedInSeconds': timeCheckedInSeconds,
  };
}
