// lib/models/athletes.dart
class Athlete {
  final String id;
  final String first_name;
  final String last_name;
  final String jersey_number;
  final String photo_url;
  final String position;
  final String birthday;
  final String current_team_id;
  String? outputId;
  String? valdId;

  Athlete({
    required this.id,
    required this.first_name,
    required this.last_name,
    required this.jersey_number,
    required this.photo_url,
    required this.position,
    required this.birthday,
    required this.current_team_id,
    this.outputId,
    this.valdId,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id']?.toString() ?? '',
      first_name: json['first_name'] ?? '',
      last_name: json['last_name'] ?? '',
      jersey_number: json['jersey']?.toString() ?? '',
      photo_url: json['image'] ?? '',
      position: json['position'] ?? '',
      birthday: json['date_of_birth_date'] ?? '',
      current_team_id: json['current_team_id'] ?? '', 
    );
  }
}

