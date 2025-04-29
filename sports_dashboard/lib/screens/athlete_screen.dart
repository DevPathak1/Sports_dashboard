import 'package:flutter/material.dart';
import 'package:sports_dashboard/models/athlete.dart';
import 'package:sports_dashboard/services/api_service.dart';
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
  const AthleteDropdownScreen({Key? key}) : super(key: key);

  @override
  State<AthleteDropdownScreen> createState() => _AthleteDropdownScreenState();
}

class _AthleteDropdownScreenState extends State<AthleteDropdownScreen> {
  List<Athlete> _athletes = [];
  Athlete? _selectedAthlete;

  @override
  void initState() {
    super.initState();
    _loadAthletes();
  }

  Future<void> _loadAthletes() async {
    try {
      final athletes = await ApiService.fetchAthletes();
      setState(() {
        _athletes = athletes;
        if (athletes.isNotEmpty) {
          _selectedAthlete = athletes.first; // default selection
        }
      });
    } catch (e) {
      print('Error loading athletes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Athlete')),
      body: _athletes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            Text('Name: ${_selectedAthlete!.first_name} ${_selectedAthlete!.last_name}', style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 8),
                            Text('Jersey #: ${_selectedAthlete!.jersey_number}'), Text('Position #: ${_selectedAthlete!.position}'), Text('Birthday: ${_selectedAthlete!.birthday}'),
                            const SizedBox(height: 16),
                            if (_selectedAthlete!.photo_url != null && _selectedAthlete!.photo_url.isNotEmpty)
                              Center(
                                child: Image.network(
                                  'https://backend-us.openfield.catapultsports.com${_selectedAthlete!.photo_url}',
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
