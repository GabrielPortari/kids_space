class Collaborator {
  final String id;
  final String name;
  final String companyId;
  final String email;
  final String? phoneNumber;
  final String? password;
  
  Collaborator({
    required this.id,
    required this.name,
    required this.companyId,
    required this.email,
    this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'companyId': companyId,
    'email': email,
    'phoneNumber': phoneNumber,
    'password': password,
  };

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    id: json['id'],
    name: json['name'],
    companyId: json['companyId'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    password: json['password'],
  );
}