
class Athlete_Output{
  final String id;
  final String first_name;
  final String last_name;

  Athlete_Output({
    required this.id,
    required this.first_name,
    required this.last_name,
  });

  factory Athlete_Output.fromJson(Map<String, dynamic> json) {
    return Athlete_Output(
      id: json['id']?.toString() ?? '',
      first_name: json['firstName'] ?? '',
      last_name: json['lastName'] ?? '',
    );
  }
}