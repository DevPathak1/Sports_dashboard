class WorkoutMetric {
  final String field;
  final dynamic value;

  WorkoutMetric({required this.field, required this.value});

  factory WorkoutMetric.fromJson(Map<String, dynamic> json) {
    return WorkoutMetric(
      field: json['field'],
      value: json['value'],
    );
  }
}

class WorkoutData {
  final String athleteId;
  final String firstName;
  final String lastName;
  final String exerciseId;
  final String exerciseType;
  final DateTime completedDate;
  final List<WorkoutMetric> metrics;
  final List<List<WorkoutMetric>> repetitions;

  WorkoutData({
    required this.athleteId,
    required this.firstName,
    required this.lastName,
    required this.exerciseId,
    required this.exerciseType,
    required this.completedDate,
    required this.metrics,
    required this.repetitions,
  });

  factory WorkoutData.fromJson(Map<String, dynamic> json) {
    return WorkoutData(
      athleteId: json['athleteId'],
      firstName: json['athleteFirstName'],
      lastName: json['athleteLastName'],
      exerciseId: json['exerciseId'],
      exerciseType: json['exerciseType'],
      completedDate: DateTime.parse(json['completedDate']),
      metrics: (json['metrics'] as List)
          .map((m) => WorkoutMetric.fromJson(m))
          .toList(),
      repetitions: (json['repetitions'] as List)
          .map((repList) => (repList as List)
              .map((m) => WorkoutMetric.fromJson(m))
              .toList())
          .toList(),
    );
  }
}
