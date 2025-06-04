class Athlete_Vald{
  final String id;
  final String first_name;
  final String last_name;

  Athlete_Vald({
    required this.id,
    required this.first_name,
    required this.last_name,
  });

  factory Athlete_Vald.fromJson(Map<String, dynamic> json) {
    return Athlete_Vald(
      id: json['profileId']?.toString() ?? '',
      first_name: json['givenName'] ?? '',
      last_name: json['familyName'] ?? '',
    );
  }
}