import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndiaPageScreen1 extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchLiveScores() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.sportradar.com/cricket-t2/en/teams/sr%3Acompetitor%3A107203/results.json?api_key=wLxVEA56I54Jxl88R7C1I88XiktCFon72A29qMs4'),
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

          // Extract scores from period_scores
          var periodScores = status['period_scores'] ?? [];
          String homeScore = '';
          String awayScore = '';

          for (var inning in periodScores) {
            if (inning['number'] == 1) {
              awayScore = inning['away_score'] != 0 ? inning['display_score'] ?? '0/0' : '0/0';
              homeScore = inning['home_score'] != 0 ? inning['display_score'] ?? '0/0' : '0/0';
            } else if (inning['number'] == 2) {
              homeScore = inning['home_score'] != 0 ? inning['display_score'] ?? '0/0' : homeScore;
              awayScore = inning['away_score'] != 0 ? inning['display_score'] ?? '0/0' : awayScore;
            }
          }

          return {
            'homeTeam': sportEvent['competitors']?[0]['name'] ?? 'Team1', // Home team is second in competitors
            'awayTeam': sportEvent['competitors']?[1]['name'] ?? 'Team2', // Away team is first in competitors
            'homeScore': homeScore,
            'awayScore': awayScore,
            'seasonName': seasonName,
            'status': status,
            'eventDetails': sportEvent,
          };
        }).toList();
      } else {
        throw Exception('Failed to load live scores');
      }
    } catch (e) {
      throw Exception('Failed to fetch live scores: $e');
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
                title: Text('${match['homeTeam']} vs ${match['awayTeam']} - Season: ${match['seasonName']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndiaPageScreen(
                        homeTeam: match['homeTeam'],
                        awayTeam: match['awayTeam'],
                        homeScore: match['homeScore'],
                        awayScore: match['awayScore'],
                        status: match['status'],
                        eventDetails: match['eventDetails'],
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



class IndiaPageScreen extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String homeScore;
  final String awayScore;
  final dynamic status;
  final Map<String, dynamic> eventDetails;
  final String seasonName;

  IndiaPageScreen({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.eventDetails,
    required this.seasonName,
  });

  @override
  Widget build(BuildContext context) {
    final displayOvers = status['display_overs']?.toString() ?? 'N/A';
    final tossWonBy = eventDetails['competitors']?.firstWhere((c) => c['id'] == status['toss_won_by'])?['name'] ?? 'N/A';
    final tossDecision = status['toss_decision']?.toString() ?? 'N/A';
    final venueName = eventDetails['venue']?['name'] ?? 'Unknown Venue';
    final winner = status['winner_id'] != null ? (eventDetails['competitors']?.firstWhere((c) => c['id'] == status['winner_id'])?['name'] ?? 'N/A') : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text('$homeTeam vs $awayTeam'),
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
              'Venue: $venueName',
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

