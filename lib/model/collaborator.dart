import 'package:kids_space/model/base_user.dart';

class Collaborator extends BaseUser {
  final String? password;

  Collaborator({
    this.password,
    super.userType,
    super.name,
    super.email,
    super.photoUrl,
    super.birthDate,
    super.document,
    super.phone,
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
  });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['password'] = password;
    return base;
  }

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);
    return Collaborator(
      password: json['password'] as String?,
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