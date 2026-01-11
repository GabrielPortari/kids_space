import 'package:kids_space/model/base_user.dart';

class Child extends BaseUser{

  final List<String>? responsibleUserIds;
  final bool? isActive;

  Child({
    super.userType,
    super.name,
    super.email,
    super.birthDate,
    super.document,
    super.phone,
    super.photoUrl,
    super.address,
    super.addressNumber,
    super.addressComplement,
    super.neighborhood,
    super.city,
    super.state,
    super.zipCode,
    super.companyId,
    super.id,
    super.createdAt,
    super.updatedAt,
    required this.responsibleUserIds, 
    required this.isActive
    });

    @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['responsibleUserIds'] = responsibleUserIds;
    base['isActive'] = isActive;
    return base;
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);
    return Child(
      responsibleUserIds: (json['responsibleUserIds'] as List<dynamic>?)?.cast<String>(),
      isActive: json['isActive'] == true,
      userType: base.userType,
      name: base.name,
      email: base.email,
      birthDate: base.birthDate,
      document: base.document,
      phone: base.phone,
      address: base.address,
      addressNumber: base.addressNumber,
      addressComplement: base.addressComplement,
      neighborhood: base.neighborhood,
      city: base.city,
      state: base.state,
      zipCode: base.zipCode,
      companyId: base.companyId,
      id: base.id,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
    );
  }

}