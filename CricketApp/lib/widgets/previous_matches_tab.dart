import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Override SSL certificate verification
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// Model for Score
class Score {
  final int runs;
  final int wickets;
  final double overs;
  final String inning;

  Score({
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.inning,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      runs: json['r'],
      wickets: json['w'],
      overs: json['o'].toDouble(),
      inning: json['inning'],
    );
  }
}

// Model for Match
class Match {
  final String id;
  final String name;
  final String status;
  final String venue;
  final String date;
  final List<String> teams;
  final List<Score> scores;

  Match({
    required this.id,
    required this.name,
    required this.status,
    required this.venue,
    required this.date,
    required this.teams,
    required this.scores,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      venue: json['venue'],
      date: json['date'],
      teams: List<String>.from(json['teams']),
      scores: (json['score'] as List)
          .map((score) => Score.fromJson(score))
          .toList(),
    );
  }
}

// Recursive function to fetch the last 10 matches from the API
Future<List<Match>> fetchFromOffset(int offset) async {
  final String apiKey = "39e36932-bc3e-44ed-9719-1c3ff327ff62";
  final String url =
      "https://api.cricapi.com/v1/currentMatches?apikey=$apiKey&offset=$offset";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] != "success") {
      throw Exception("Failed to load data");
    }

    List<dynamic> dataArray = data['data'];

    if (dataArray == null || dataArray.isEmpty) {
      return [];
    } else if (dataArray.length >= 10 || offset >= data['info']['totalRows']) {
      // Return only the last 10 matches
      return dataArray
          .take(10)
          .map((matchJson) => Match.fromJson(matchJson))
          .toList();
    } else {
      // Fetch the next set of matches recursively
      List<Match> nextData = await fetchFromOffset(offset + 25);
      return dataArray
          .take(10)
          .map((matchJson) => Match.fromJson(matchJson))
          .toList();
    }
  } else {
    throw Exception('Failed to load data');
  }
}

// Main Application
void main() {
  HttpOverrides.global = MyHttpOverrides(); // Add this line to override SSL verification
  runApp(CricketApp());
}

class CricketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Matches',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PreviousMatchesTab(),
    );
  }
}

// PreviousMatchesTab to display the list of matches
class PreviousMatchesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Matches'),
      ),
      body: FutureBuilder<List<Match>>(
        future: fetchFromOffset(0),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No matches available'));
          }

          final matches = snapshot.data!;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];

              return ListTile(
                title: Text('${match.teams[0]} vs ${match.teams[1]}'),
                subtitle: Text(match.status),
                onTap: () {
                  // Navigate to MatchDetailsScreen when the button is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchDetailsScreen(match: match),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// MatchDetailsScreen to display match details
class MatchDetailsScreen extends StatelessWidget {
  final Match match;

  MatchDetailsScreen({required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${match.teams[0]} vs ${match.teams[1]}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Match: ${match.name}', style: TextStyle(fontSize: 20)),
            Text('Status: ${match.status}', style: TextStyle(fontSize: 16)),
            Text('Venue: ${match.venue}', style: TextStyle(fontSize: 16)),
            Text('Date: ${match.date}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Scores:', style: TextStyle(fontSize: 18)),
            ...match.scores.map((score) => Text(
              '${score.inning}: ${score.runs}/${score.wickets} in ${score.overs} overs',
              style: TextStyle(fontSize: 16),
            )),
          ],
        ),
      ),
    );
  }
}
