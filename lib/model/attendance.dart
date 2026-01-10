import 'package:kids_space/model/base_model.dart';

enum AttendanceType {
  checkin,
  checkout,
}

class Attendance extends BaseModel{
    final AttendanceType? attendanceType;
    final String? notes;
    final String? companyId;
    final String? collaboratorCheckedInId;
    final String? collaboratorCheckedOutId;
    final String? responsibleId;
    final String? childId;
    final DateTime? checkinTime;
    final DateTime? checkoutTime;

  Attendance({
    required super.id, 
    required super.createdAt, 
    required super.updatedAt, 
    this.attendanceType, 
    this.notes, 
    this.companyId, 
    this.collaboratorCheckedInId, 
    this.collaboratorCheckedOutId, 
    this.responsibleId, 
    this.childId, 
    this.checkinTime, 
    this.checkoutTime, 
    });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['companyId'] = companyId;
    base['notes'] = notes;
    base['childId'] = childId;
    base['collaboratorCheckedInId'] = collaboratorCheckedInId;
    base['collaboratorCheckedOutId'] = collaboratorCheckedOutId;
    base['responsibleId'] = responsibleId;
    base['checkinTime'] = checkinTime?.toIso8601String();
    base['checkoutTime'] = checkoutTime?.toIso8601String();
    base['attendanceType'] = attendanceType == null
        ? null
        : (attendanceType == AttendanceType.checkin ? 'checkin' : 'checkout');
    return base;
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final created = BaseModel.tryParseTimestamp(json['createdAt']);
    final updated = BaseModel.tryParseTimestamp(json['updatedAt']) ?? created;
    DateTime? checkinTime = BaseModel.tryParseTimestamp(json['checkinTime']);
    DateTime? checkoutTime = BaseModel.tryParseTimestamp(json['checkoutTime']);
    AttendanceType? type;
    final t = json['attendanceType'];
    if (t is String) {
      if (t.toLowerCase() == 'checkin' || t == 'checkIn') type = AttendanceType.checkin;
      if (t.toLowerCase() == 'checkout' || t == 'checkOut') type = AttendanceType.checkout;
    }

    return Attendance(
      id: json['id'] as String?,
      createdAt: created,
      updatedAt: updated,
      notes: json['notes'] as String?,
      companyId: json['companyId'] as String?,
      childId: json['childId'] as String?,
      responsibleId: json['responsibleId'] as String?,
      collaboratorCheckedInId: json['collaboratorCheckedInId'] as String?,
      collaboratorCheckedOutId: json['collaboratorCheckedOutId'] as String?,
      checkinTime: checkinTime,
      checkoutTime: checkoutTime,
      attendanceType: type,
    );
  }

}