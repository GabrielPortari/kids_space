import 'package:kids_space/model/base_user.dart';

class User extends BaseUser{

  final List<String>? childrenIds; 

  User({
    this.childrenIds,
    super.userType,
    super.name,
    super.email,
    super.photoUrl,
    super.birthDate,
    super.document,
    super.phone,
    super.address,
    super.adressNumber,
    super.adressComplement,
    super.neighborhood,
    super.city,
    super.state,
    super.zipCode,
    super.companyId,
    super.id,
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['childrenIds'] = childrenIds;
    return base;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);
    return User(
      childrenIds: (json['childrenIds'] as List<dynamic>?)?.cast<String>(),
      userType: base.userType,
      name: base.name,
      email: base.email,
      birthDate: base.birthDate,
      document: base.document,
      phone: base.phone,
      address: base.address,
      adressNumber: base.adressNumber,
      adressComplement: base.adressComplement,
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