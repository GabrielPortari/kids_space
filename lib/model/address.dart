class Address {
  final String? address;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? zipcode;

  Address({
    this.address,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.zipcode,
  });

  Map<String, dynamic> toJson() => {
    'address': address,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'zipcode': zipcode,
  };

  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Address();
    return Address(
      address: json['address'] as String?,
      number: json['number'] as String? ?? json['addressNumber'] as String?,
      complement:
          json['complement'] as String? ?? json['addressComplement'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipcode: json['zipcode'] as String? ?? json['zipCode'] as String?,
    );
  }
}
