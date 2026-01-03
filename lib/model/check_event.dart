import 'package:kids_space/model/base_model.dart';

enum CheckType {
  checkIn,
  checkOut,
}

class CheckEvent extends BaseModel{
  final String? companyId;
  final String? childId;
  final String? collaboratorId;
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final CheckType? checkType;

  CheckEvent({
    required super.id, 
    required super.createdAt, 
    required super.updatedAt, 
    this.companyId, this.childId, 
    this.collaboratorId, 
    this.checkinTime, 
    this.checkoutTime, 
    this.checkType
    });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['companyId'] = companyId;
    base['childId'] = childId;
    base['collaboratorId'] = collaboratorId;
    base['checkinTime'] = checkinTime?.toIso8601String();
    base['checkoutTime'] = checkoutTime?.toIso8601String();
    base['checkType'] = checkType == null
        ? null
        : (checkType == CheckType.checkIn ? 'checkIn' : 'checkOut');
    return base;
  }

  factory CheckEvent.fromJson(Map<String, dynamic> json) {
    final created = BaseModel.tryParseTimestamp(json['createdAt']);
    final updated = BaseModel.tryParseTimestamp(json['updatedAt']) ?? created;
    DateTime? checkin = BaseModel.tryParseTimestamp(json['checkinTime']);
    DateTime? checkout = BaseModel.tryParseTimestamp(json['checkoutTime']);
    CheckType? type;
    final t = json['checkType'];
    if (t is String) {
      if (t.toLowerCase() == 'checkin' || t == 'checkIn') type = CheckType.checkIn;
      if (t.toLowerCase() == 'checkout' || t == 'checkOut') type = CheckType.checkOut;
    }

    return CheckEvent(
      id: json['id'] as String?,
      createdAt: created,
      updatedAt: updated,
      companyId: json['companyId'] as String?,
      childId: json['childId'] as String?,
      collaboratorId: json['collaboratorId'] as String?,
      checkinTime: checkin,
      checkoutTime: checkout,
      checkType: type,
    );
  }

}