import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreviousMatchesTab extends StatelessWidget {
  final bool isIndiaOnly;

  PreviousMatchesTab({this.isIndiaOnly = true});

  Future<List<dynamic>> fetchPreviousMatches() async {
    final response = await http.get(Uri.parse('https://api.sportradar.com/cricket-t1/en/teams/{team_id}/results.json?api_key=your_api_key'));

    if (response.statusCode == 200) {
      List<dynamic> matches = json.decode(response.body)['matches'];
      if (isIndiaOnly) {
        return matches.where((match) => match['team']['name'] == 'India').toList();
      }
      return matches;
    } else {
      throw Exception('Failed to load previous matches');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchPreviousMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No previous matches available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var match = snapshot.data![index];
              return ListTile(
                title: Text(match['title']),
                subtitle: Text('Result: ${match['result']}'),
              );
            },
          );
        }
      },
    );
  }
}
