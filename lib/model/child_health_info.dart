class Medication {
  final String? name;
  final String? dosage;
  final String? schedule;

  Medication({this.name, this.dosage, this.schedule});

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    name: json['name'] as String?,
    dosage: json['dosage'] as String?,
    schedule: json['schedule'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'schedule': schedule,
  };

  Medication copyWith({String? name, String? dosage, String? schedule}) =>
      Medication(
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        schedule: schedule ?? this.schedule,
      );
}

class ChildHealthInfo {
  final List<String>? dietaryRestrictions;
  final List<String>? allergies;
  final List<Medication>? medications;
  final List<String>? medicalConditions;
  final List<String>? fearsOrSensitivities;

  ChildHealthInfo({
    this.dietaryRestrictions,
    this.allergies,
    this.medications,
    this.medicalConditions,
    this.fearsOrSensitivities,
  });

  factory ChildHealthInfo.fromJson(Map<String, dynamic> json) =>
      ChildHealthInfo(
        dietaryRestrictions:
            (json['dietaryRestrictions'] as List<dynamic>?)?.cast<String>(),
        allergies: (json['allergies'] as List<dynamic>?)?.cast<String>(),
        medications: (json['medications'] as List<dynamic>?)
            ?.whereType<Map>()
            .map(
              (m) =>
                  Medication.fromJson(Map<String, dynamic>.from(m.map((k, v) => MapEntry(k.toString(), v)))),
            )
            .toList(),
        medicalConditions:
            (json['medicalConditions'] as List<dynamic>?)?.cast<String>(),
        fearsOrSensitivities:
            (json['fearsOrSensitivities'] as List<dynamic>?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'dietaryRestrictions': dietaryRestrictions,
    'allergies': allergies,
    'medications': medications?.map((m) => m.toJson()).toList(),
    'medicalConditions': medicalConditions,
    'fearsOrSensitivities': fearsOrSensitivities,
  };

  ChildHealthInfo copyWith({
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<Medication>? medications,
    List<String>? medicalConditions,
    List<String>? fearsOrSensitivities,
  }) =>
      ChildHealthInfo(
        dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
        allergies: allergies ?? this.allergies,
        medications: medications ?? this.medications,
        medicalConditions: medicalConditions ?? this.medicalConditions,
        fearsOrSensitivities: fearsOrSensitivities ?? this.fearsOrSensitivities,
      );

  bool get isEmpty =>
      (dietaryRestrictions?.isEmpty ?? true) &&
      (allergies?.isEmpty ?? true) &&
      (medications?.isEmpty ?? true) &&
      (medicalConditions?.isEmpty ?? true) &&
      (fearsOrSensitivities?.isEmpty ?? true);
}
