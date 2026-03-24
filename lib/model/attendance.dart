import 'base_model.dart';

enum AttendanceType { checkin, checkout }

class Attendance extends BaseModel {
  final AttendanceType? attendanceType;
  final String? notes;
  final String? companyId;
  final String? collaboratorWhoCheckedInId;
  final String? collaboratorWhoCheckedOutId;
  final String? responsibleIdWhoCheckedInId;
  final String? responsibleIdWhoCheckedOutId;
  final String? childId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int? timeCheckedInSeconds;

  Attendance({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.attendanceType,
    this.notes,
    this.companyId,
    this.collaboratorWhoCheckedInId,
    this.collaboratorWhoCheckedOutId,
    this.responsibleIdWhoCheckedInId,
    this.responsibleIdWhoCheckedOutId,
    this.childId,
    this.checkInTime,
    this.checkOutTime,
    this.timeCheckedInSeconds,
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
      responsibleIdWhoCheckedInId:
          json['responsibleIdWhoCheckedInId'] as String? ??
          json['responsibleId'] as String?,
      responsibleIdWhoCheckedOutId:
          json['responsibleIdWhoCheckedOutId'] as String?,
      childId: json['childId'] as String?,
      checkInTime: inTime,
      checkOutTime: outTime,
      timeCheckedInSeconds: json['timeCheckedInSeconds'] is int
          ? json['timeCheckedInSeconds'] as int
          : (json['timeCheckedInSeconds'] is String
                ? int.tryParse(json['timeCheckedInSeconds'])
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
    'responsibleIdWhoCheckedInId': responsibleIdWhoCheckedInId,
    'responsibleId': responsibleIdWhoCheckedInId,
    'responsibleIdWhoCheckedOutId': responsibleIdWhoCheckedOutId,
    'childId': childId,
    'checkInTime': checkInTime?.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'timeCheckedInSeconds': timeCheckedInSeconds,
  };
}
