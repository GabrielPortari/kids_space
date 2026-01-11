import 'package:kids_space/model/base_model.dart';

enum UserType {
  child,
  user,
  collaborator,
  admin
}

class BaseUser extends BaseModel{
  final UserType? userType;
  final String? photoUrl;
  final String? name;
  final String? email;
  final String? birthDate;
  final String? document;
  final String? phone;
  
  final String? address;
  final String? addressNumber;
  final String? addressComplement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? companyId;

  BaseUser({
    this.userType, 
    this.photoUrl,
    this.name, 
    this.email, 
    this.birthDate, 
    this.document, 
    this.phone, 
    this.address, 
    this.addressNumber, 
    this.addressComplement, 
    this.neighborhood, 
    this.city, 
    this.state, 
    this.zipCode, 
    this.companyId, 
    super.id, 
    super.createdAt, 
    super.updatedAt
  });

  @override
  Map<String, dynamic> toJson() {
        final base = super.toJson();
        base['userType'] = userType?.toString().split('.').last;
        base['photoUrl'] = photoUrl;
        base['name'] = name;
        base['email'] = email;
        base['birthDate'] = birthDate;
        base['document'] = document;
        base['phone'] = phone;
        base['address'] = address;
        base['addressNumber'] = addressNumber;
        base['addressComplement'] = addressComplement;
        base['neighborhood'] = neighborhood;
        base['city'] = city;
        base['state'] = state;
        base['zipCode'] = zipCode;
        base['companyId'] = companyId;
        return base;
      }

  factory BaseUser.fromJson(Map<String, dynamic> json) {
    final raw = json['userType'];
    UserType? parsedUserType;

    if (raw != null) {
      final rawStr = raw.toString();
      try {
        if (rawStr.contains('.')) {
          parsedUserType = UserType.values.firstWhere((e) => e.toString() == rawStr);
        } else {
          parsedUserType = UserType.values.firstWhere((e) => e.toString() == 'UserType.$rawStr');
        }
      } catch (_) {
        parsedUserType = null;
      }
    }

    return BaseUser(
      id: json['id'] as String?,
      userType: parsedUserType,
      photoUrl: json['photoUrl'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      birthDate: json['birthDate'] as String?,
      document: json['document'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      addressNumber: json['addressNumber'] as String?,
      addressComplement: json['addressComplement'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      companyId: json['companyId'] as String?,
      createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
      updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
    );
  }
}