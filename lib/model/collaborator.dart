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

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    final raw = json['userType'];
    UserType parsedUserType = UserType.collaborator;

    if (raw != null) {
      final rawStr = raw.toString();
      try {
        if (rawStr.contains('.')) {
          // Accept full enum string like 'UserType.admin' or just the enum name 'admin'
          parsedUserType = UserType.values.firstWhere((e) => e.toString() == rawStr);
        } else {
          parsedUserType = UserType.values.firstWhere((e) => e.toString() == 'UserType.$rawStr');
        }
      } catch (_) {
        // fallback to collaborator if parsing fails
        parsedUserType = UserType.collaborator;
      }
    }

    return Collaborator(
      id: json['id'],
      name: json['name'],
      companyId: json['companyId'],
      email: json['email'],
      userType: parsedUserType,
      phoneNumber: json['phoneNumber'],
      password: json['password'],
    );
  }
}