import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveScoresTab extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchLiveScores() async {
    final response = await http.get(
      Uri.parse('https://api.sportradar.com/cricket-t2/en/schedules/2024-01-06/results.json?api_key=wLxVEA56I54Jxl88R7C1I88XiktCFon72A29qMs4'),
      headers: {
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> results = data['results'] ?? [];
      return results.map((result) {
        var sportEvent = result['sport_event'];
        var seasonName = sportEvent['season']['name'] ?? 'Unknown Season';
        var status = result['sport_event_status'];

        return {
          'homeTeam': sportEvent['competitors']?[0]['name'] ?? 'Team1',
          'awayTeam': sportEvent['competitors']?[1]['name'] ?? 'Team2',
          'seasonName': seasonName,
          'status': status,
        };
      }).toList();
    } else {
      throw Exception('Failed to load live scores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchLiveScores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No live scores available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final match = snapshot.data![index];

              return ListTile(
                title: Text('${match['homeTeam']} Vs ${match['awayTeam']} - Season: ${match['seasonName']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchDetailsScreen(
                        homeTeam: match['homeTeam'],
                        awayTeam: match['awayTeam'],
                        status: match['status'],
                        seasonName: match['seasonName'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class MatchDetailsScreen extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final dynamic status;
  final String seasonName;

  MatchDetailsScreen({
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    required this.seasonName,
  });

  @override
  Widget build(BuildContext context) {
    final homeScore = status['period_scores'] != null && status['period_scores'][0] != null
        ? status['period_scores'][0]['display_score'] ?? 'No data'
        : 'No data';
    final awayScore = status['period_scores'] != null && status['period_scores'][1] != null
        ? status['period_scores'][1]['display_score'] ?? 'No data'
        : 'No data';
    final displayOvers = status['display_overs']?.toString() ?? 'N/A';
    final tossWonBy = status['toss_won_by']?.toString() ?? 'N/A';
    final tossDecision = status['toss_decision']?.toString() ?? 'N/A';
    final winner = status['winner_id']?.toString() ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text('$homeTeam Vs $awayTeam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Season: $seasonName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          homeTeam,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          homeScore,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          awayTeam,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          awayScore,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Overs: $displayOvers',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Toss: $tossWonBy chose to $tossDecision',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Winner: $winner',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}