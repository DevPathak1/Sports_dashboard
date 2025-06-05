import 'package:flutter/material.dart';
import 'package:sports_dashboard/models/athlete.dart';
import 'package:sports_dashboard/models/workout_data.dart';
import 'package:sports_dashboard/services/api_service.dart';
import 'package:sports_dashboard/services/api_output.dart';
import 'package:sports_dashboard/services/api_vald.dart';
import 'package:sports_dashboard/models/smartspeed.dart';
import 'package:sports_dashboard/services/smartspeed_api.dart' as SmartSpeedApi;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
Future<Uint8List> _loadAuthenticatedImage(String url) async {
  final token = dotenv.env['API_TOKEN'];
  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  print('🔍 Status: ${response.statusCode}');
  print('🔍 Content-Type: ${response.headers['content-type']}');
  print('🔍 Redirected to: ${response.request?.url}');

  if (response.statusCode == 200 &&
      response.headers['content-type']?.startsWith('image/') == true) {
    return response.bodyBytes;
  } else {
    throw Exception('Invalid image or unauthorized: ${response.statusCode}');
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

  List<SmartSpeedTest> _smartSpeedTests = [];
  SmartSpeedTest? _selectedSmartSpeedTest;
  bool _isLoadingTests = false;

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

  Future<void> _loadSmartSpeedTests(String? valdId) async {
    if (valdId == null || valdId.isEmpty) {
      setState(() {
        _smartSpeedTests = [];
        _selectedSmartSpeedTest = null;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingTests = true;
      });

      final tests = await SmartSpeedApi.ValdApiService.fetchsmartSpeedTests(valdId);
      setState(() {
        _smartSpeedTests = tests;
        _selectedSmartSpeedTest = tests.isNotEmpty ? tests.first : null;
      });
    } catch (e) {
      print('❌ Error fetching SmartSpeed tests: $e');
    } finally {
      setState(() {
        _isLoadingTests = false;
      });
    }
  }

  Future<void> _loadAthletes() async {
    try {
      final allAthletes = await ApiService.fetchAthletes();
      final athletes = allAthletes
          .where((athlete) => athlete.current_team_id=='75054b55-9900-11e3-b9b6-22000af8166b')
          .toList();
      
      for(var athlete in allAthletes.take(5)){
        print('Athlete: ${athlete.current_team_id}');
      }
      print(athletes);

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

final valdMatch = valdAthletes.where(
  (vald) =>
    _normalize(vald.first_name) == _normalize(athlete.first_name) &&
    _normalize(vald.last_name) == _normalize(athlete.last_name),
).toList();

if (valdMatch.isNotEmpty) {
  print('✅ Found Vald match for ${athlete.first_name} ${athlete.last_name}');
  athlete.valdId = valdMatch.first.id;
} else {
  print('⚠️ No Vald match for ${athlete.first_name} ${athlete.last_name}');
}

  }

  await _loadWorkoutData(matchedIds);
  if (_selectedAthlete?.valdId != null) {
    await _loadSmartSpeedTests(_selectedAthlete!.valdId);
  }

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
                          await _loadSmartSpeedTests(newValue?.valdId);
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
                    const SizedBox(height: 12),
                    if (_smartSpeedTests.isNotEmpty)
                      DropdownButton<SmartSpeedTest>(
                        value: _selectedSmartSpeedTest,
                        isExpanded: true,
                        hint: const Text('Select SmartSpeed Test'),
                        onChanged: (SmartSpeedTest? newTest) {
                          setState(() {
                            _selectedSmartSpeedTest = newTest;
                          });
                        },
                        items: _smartSpeedTests.map((test) {
                          return DropdownMenuItem<SmartSpeedTest>(
                            value: test,
                            child: Text(test.testName),
                          );
                        }).toList(),
                      ),
                    if (_selectedSmartSpeedTest != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Test: \${_selectedSmartSpeedTest!.testName} (\${_selectedSmartSpeedTest!.testTypeName})',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Date: \${_selectedSmartSpeedTest!.testDateUtc.toLocal().toIso8601String().split("T").first}'),
                                Text('Valid: \${_selectedSmartSpeedTest!.isValid}'),
                                Text('Device Count: \${_selectedSmartSpeedTest!.deviceCount}'),
                                Text('Rep Count: \${_selectedSmartSpeedTest!.repCount}'),
                                if (_selectedSmartSpeedTest!.runningSummaryFields != null) ...[
                                  const SizedBox(height: 8),
                                  const Text('Running Summary:', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text('Total Time: \${_selectedSmartSpeedTest!.runningSummaryFields!.totalTimeSeconds}s'),
                                  Text('Best Split: \${_selectedSmartSpeedTest!.runningSummaryFields!.bestSplitSeconds}s'),
                                  Text('Average Split: \${_selectedSmartSpeedTest!.runningSummaryFields!.splitAverageSeconds}s'),
                                  if (_selectedSmartSpeedTest!.runningSummaryFields!.gateSummaryFields != null) ...[
                                    const SizedBox(height: 8),
                                    const Text('Gate Summary:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text('Split 1: \${_selectedSmartSpeedTest!.runningSummaryFields!.gateSummaryFields!.splitOne}s'),
                                    Text('Split 2: \${_selectedSmartSpeedTest!.runningSummaryFields!.gateSummaryFields!.splitTwo}s'),
                                    Text('Split 3: \${_selectedSmartSpeedTest!.runningSummaryFields!.gateSummaryFields!.splitThree}s'),
                                    Text('Split 4: \${_selectedSmartSpeedTest!.runningSummaryFields!.gateSummaryFields!.splitFour}s'),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
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
                                FutureBuilder<Uint8List>(
                                  future: _loadAuthenticatedImage(
                                    'https://backend-us.openfield.catapultsports.com${_selectedAthlete!.photo_url}',
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError || !snapshot.hasData) {
                                      return const Center(child: Icon(Icons.broken_image, size: 100));
                                    } else {
                                      return Center(
                                        child: Image.memory(snapshot.data!, height: 150),
                                      );
                                    }
                                  },
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