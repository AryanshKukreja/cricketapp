import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveScoresTab extends StatelessWidget {
  final bool isIndiaOnly;

  LiveScoresTab({this.isIndiaOnly = true});

  Future<List<dynamic>> fetchLiveScores() async {
    final response = await http.get(
      Uri.parse('https://api.sportradar.us/cricket-t2/en/schedules/live/schedule.json?api_key=wLxVEA56I54Jxl88R7C1I88XiktCFon72A29qMs4'),
      headers: {
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      var data = json.decode(response.body);
      List<dynamic> scores = data['sport_events'] ?? [];

      if (isIndiaOnly) {
        return scores.where((match) => match['competitors'].any((team) => team['name'] == 'India')).toList();
      }

      return scores;
    } else {
      print('Failed to load live scores. Status code: ${response.statusCode}');
      throw Exception('Failed to load live scores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchLiveScores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No scores available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final match = snapshot.data![index];
              return ListTile(
                title: Text(match['competitors'][0]['name'] ?? 'Unknown Team'),
                subtitle: Text(match['competitors'][1]['name'] ?? 'Unknown Team'),
              );
            },
          );
        }
      },
    );
  }
}
