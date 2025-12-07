enum UserType {
  collaborator,
  admin
}

class Collaborator {
  final String id;
  final String name;
  final String companyId;
  final String email;
  final UserType userType;
  final String? phoneNumber;
  final String? password;
  
  Collaborator({
    required this.id,
    required this.name,
    required this.companyId,
    required this.email,
    required this.userType,
    this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'companyId': companyId,
    'email': email,
    'userType': userType.toString().split('.').last,
    'phoneNumber': phoneNumber,
  };

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    id: json['id'],
    name: json['name'],
    companyId: json['companyId'],
    email: json['email'],
    userType: UserType.values.firstWhere((e) => e.toString() == 'UserType.${json['userType']}'),
    phoneNumber: json['phoneNumber'],
    password: json['password'],
  );
}