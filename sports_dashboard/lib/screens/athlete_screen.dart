import 'package:flutter/material.dart';
import 'package:sports_dashboard/models/athlete.dart';
import 'package:sports_dashboard/models/workout_data.dart';
import 'package:sports_dashboard/services/api_service.dart';
import 'package:sports_dashboard/services/api_output.dart';
import 'package:sports_dashboard/services/api_vald.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> fetchImageBytes(String imageUrl, String token) async {
  final response = await http.get(
    Uri.parse(imageUrl),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}

class AthleteDropdownScreen extends StatefulWidget {
  const AthleteDropdownScreen({super.key});

  @override
  State<AthleteDropdownScreen> createState() => _AthleteDropdownScreenState();
}

class _AthleteDropdownScreenState extends State<AthleteDropdownScreen> {
  List<Athlete> _athletes = [];
  Athlete? _selectedAthlete;

  List<WorkoutData> _workoutData = [];
  List<Map<String, dynamic>> _exerciseOptions = [];
  Map<String, dynamic>? _selectedExercise;

  bool _isLoadingWorkouts = false;

  String _normalize(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> _loadWorkoutData(List<String> athleteIds) async {
    try {
      if (athleteIds.isEmpty || _selectedExercise == null) {
        print('⚠️ No athlete IDs or exercise selected — skipping workout fetch.');
        return;
      }

      setState(() {
        _isLoadingWorkouts = true;
      });

      final startDate = DateTime(2025, 4, 1);
      final endDate = DateTime(2025, 5, 1);
      final Duration maxRange = const Duration(days: 31);

      List<WorkoutData> allWorkouts = [];
      DateTime currentStart = startDate;

      while (currentStart.isBefore(endDate)) {
        final currentEnd = currentStart.add(maxRange);
        final cappedEnd = currentEnd.isAfter(endDate) ? endDate : currentEnd;

        final rawWorkouts = await OutputApiService.fetchWorkoutData(
          athleteIds,
          currentStart,
          cappedEnd,
          exerciseId: _selectedExercise!['id'],
        );

        try {
          final parsed = rawWorkouts.map((item) => WorkoutData.fromJson(item)).toList();
          allWorkouts.addAll(parsed);
        } catch (e, stack) {
        print('❌ Error parsing workouts: $e');
        print(stack);
}


        currentStart = cappedEnd.add(const Duration(days: 1));
      }

      print('✅ Total workouts fetched: ${allWorkouts.length}');

      // Filter workouts for selected athlete
      final workoutsForSelected = allWorkouts.where(
        (w) =>
            _normalize(w.firstName) ==
                _normalize(_selectedAthlete?.first_name ?? '') &&
            _normalize(w.lastName) ==
                _normalize(_selectedAthlete?.last_name ?? ''),
      ).toList();

      setState(() {
        _workoutData = workoutsForSelected;
      });
    } catch (e) {
      print('❌ Error fetching workout data: $e');
    } finally {
      setState(() {
        _isLoadingWorkouts = false;
      });
    }
  }

  Future<void> _loadAthletes() async {
    try {
      final allAthletes = await ApiService.fetchAthletes();
      final athletes = allAthletes
          .where((athlete) => athlete.tag_list.contains('2024 Starter'))
          .toList();

      final outputAthletes = await OutputApiService.fetchOutputAthletes();
      final valdAthletes = await ValdApiService().fetchAthletes(
        '2549e0dc-292c-4820-a9ec-1f72652178e1',
        'a5132d0c-bddf-4827-8571-fec043a2c87f',
      );
final exercises = await OutputApiService.fetchExerciseMetadata();

setState(() {
  _athletes = athletes;
  _exerciseOptions = exercises;
  if (athletes.isNotEmpty) {
    _selectedAthlete = athletes.first;
  }
  if (exercises.isNotEmpty) {
    _selectedExercise = exercises.first;
  }
});

final matchedIds = <String>[];

for (final athlete in athletes) {
  final match = outputAthletes.where(
    (out) =>
      _normalize(out.first_name) == _normalize(athlete.first_name) &&
      _normalize(out.last_name) == _normalize(athlete.last_name),
  ).toList();
  if (match.isNotEmpty) {
    matchedIds.add(match.first.id);
  } else {
    print('⚠️ No Output match for ${athlete.first_name} ${athlete.last_name}');
  }

/*  final valdMatch = valdAthletes.where(
  (vald) =>
    _normalize(vald.first_name) == _normalize(athlete.first_name) &&
    _normalize(vald.last_name) == _normalize(athlete.last_name),
).toList();

if (valdMatch.isNotEmpty) {
  print('✅ Found Vald match for ${athlete.first_name} ${athlete.last_name}');
  athlete.valdId = valdMatch.first.id;
} else {
  print('⚠️ No Vald match for ${athlete.first_name} ${athlete.last_name}');
}*/

}

await _loadWorkoutData(matchedIds);

    } catch (e) {
      print('❌ Error loading athletes or workout data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAthletes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Athlete')),
      body: _athletes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButton<Athlete>(
                      value: _selectedAthlete,
                      isExpanded: true,
                      onChanged: (Athlete? newValue) async {
                        setState(() {
                          _selectedAthlete = newValue;
                        });

                        final outputAthletes = await OutputApiService.fetchOutputAthletes();
                        final matches = outputAthletes.where(
                          (out) =>
                            _normalize(out.first_name) == _normalize(newValue?.first_name ?? '') &&
                            _normalize(out.last_name) == _normalize(newValue?.last_name ?? ''),
                        ).toList();

                        if (matches.isNotEmpty) {
                          final match = matches.first;
                          _loadWorkoutData([match.id]);
                        } else {
                          print('⚠️ No matching Output athlete for ${newValue?.first_name} ${newValue?.last_name}');
                        }
                      },
                      items: _athletes
                          .map<DropdownMenuItem<Athlete>>((Athlete athlete) {
                        return DropdownMenuItem<Athlete>(
                          value: athlete,
                          child: Text('${athlete.first_name} ${athlete.last_name}'),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    if (_exerciseOptions.isNotEmpty)
                      DropdownButton<Map<String, dynamic>>(
                        value: _selectedExercise,
                        isExpanded: true,
                        hint: const Text('Select Exercise'),
                        onChanged: (Map<String, dynamic>? newValue) async {
                          setState(() {
                            _selectedExercise = newValue;
                          });

                          if (_selectedAthlete != null) {
                            final outputAthletes = await OutputApiService.fetchOutputAthletes();

                            final matches = outputAthletes.where(
                              (out) =>
                                _normalize(out.first_name) == _normalize(_selectedAthlete!.first_name) &&
                                _normalize(out.last_name) == _normalize(_selectedAthlete!.last_name),
                            ).toList();

                            if (matches.isNotEmpty) {
                              await _loadWorkoutData([matches.first.id]);
                            } else {
                              print('⚠️ No matching Output athlete for ${_selectedAthlete!.first_name} ${_selectedAthlete!.last_name}');
                            }
                          }
                        },
                        items: _exerciseOptions.map((exercise) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: exercise,
                            child: Text(exercise['name']),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    if (_selectedAthlete != null)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${_selectedAthlete!.first_name} ${_selectedAthlete!.last_name}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 8),
                              Text('Jersey #: ${_selectedAthlete!.jersey_number}'),
                              Text('Position #: ${_selectedAthlete!.position}'),
                              Text('Birthday: ${_selectedAthlete!.birthday}'),
                              const SizedBox(height: 16),
                              if (_selectedAthlete!.photo_url.isNotEmpty)
                                Center(
                                  child: Image.network(
                                    'https://backend-us.openfield.catapultsports.com${_selectedAthlete!.photo_url}',
                                    height: 150,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image, size: 100),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_selectedAthlete != null &&
                        !_isLoadingWorkouts &&
                        _workoutData.isNotEmpty)
                      ..._workoutData.map((data) => Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Card(
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Workout: ${data.exerciseId} (${data.exerciseType})',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('Date: ${data.completedDate.toLocal().toIso8601String().split("T").first}'),
                                    const SizedBox(height: 8),
                                    const Text('Metrics:',
                                        style: TextStyle(fontWeight: FontWeight.w500)),
                                    ...data.metrics.map((m) =>
                                        Text('${m.field}: ${m.value}')),
                                    const SizedBox(height: 8),
                                    const Text('Repetitions:',
                                        style: TextStyle(fontWeight: FontWeight.w500)),
                                    ...data.repetitions.asMap().entries.map((entry) {
                                      final rep = entry.value;
                                      return Text('Rep ${entry.key + 1}: ${rep.map((r) => '${r.field}: ${r.value}').join(", ")}');
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}