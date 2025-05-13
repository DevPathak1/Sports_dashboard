import 'package:flutter/material.dart';
import 'package:sports_dashboard/models/athlete.dart';
import 'package:sports_dashboard/models/workout_data.dart';
import 'package:sports_dashboard/services/api_service.dart';
import 'package:sports_dashboard/services/api_output.dart';
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
  bool _isLoadingWorkouts = false;

  Future<void> _loadWorkoutData(List<String> athleteIds) async {
  try {
    if (athleteIds.isEmpty) {
      print('⚠️ No athlete IDs — skipping workout fetch.');
      return;
    }

    setState(() {
      _isLoadingWorkouts = true;
    });

    final startDate = DateTime(2025, 4, 1);
    final endDate = DateTime(2025, 5, 1);

    final data = await OutputApiService.fetchWorkoutData(
      athleteIds,
      startDate,
      endDate,
    );

    print('📊 Workout data returned: ${data.length}');
    setState(() {
      _workoutData = data;
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

      setState(() {
        _athletes = athletes;
        if (athletes.isNotEmpty) {
          _selectedAthlete = athletes.first;
        }
      });

      final outputAthletes = await OutputApiService.fetchOutputAthletes();

      final matchedIds = <String>[];

      for (final athlete in athletes) {
        final matches = outputAthletes.where(
          (out) =>
              out.first_name == athlete.first_name &&
              out.last_name == athlete.last_name,
        ).toList();
        if (matches.isNotEmpty) {
          matchedIds.add(matches.first.id);

        } else {
          print('⚠️ No match for ${athlete.first_name} ${athlete.last_name}');
        }
      }
      print('✅ Matched athlete IDs: $matchedIds');
      await _loadWorkoutData(matchedIds);
    } catch (e) {
      print('Error loading athletes or workout data: $e');
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<Athlete>(
                    value: _selectedAthlete,
                    isExpanded: true,
                    onChanged: (Athlete? newValue) {
                      setState(() {
                        _selectedAthlete = newValue;
                      });
                    },
                    items: _athletes.map<DropdownMenuItem<Athlete>>((Athlete athlete) {
                      return DropdownMenuItem<Athlete>(
                        value: athlete,
                        child: Text('${athlete.first_name} ${athlete.last_name}'),
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
                            Text('Name: ${_selectedAthlete!.first_name} ${_selectedAthlete!.last_name}',
                                style: const TextStyle(fontSize: 20)),
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 100),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_selectedAthlete != null && !_isLoadingWorkouts)
                    ..._workoutData
                        .where((d) =>
                            d.firstName.toLowerCase().trim() ==
                                _selectedAthlete!.first_name.toLowerCase().trim() &&
                            d.lastName.toLowerCase().trim() ==
                                _selectedAthlete!.last_name.toLowerCase().trim())
                        .map((data) => Padding(
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
                                      const Text('Metrics:', style: TextStyle(fontWeight: FontWeight.w500)),
                                      ...data.metrics.map((m) => Text('${m.field}: ${m.value}')),
                                      const SizedBox(height: 8),
                                      const Text('Repetitions:', style: TextStyle(fontWeight: FontWeight.w500)),
                                      ...data.repetitions.asMap().entries.map((entry) {
                                        final rep = entry.value;
                                        return Text(
                                            'Rep ${entry.key + 1}: ${rep.map((r) => '${r.field}: ${r.value}').join(", ")}');
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                ],
              ),
            ),
    );
  }
}
