import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpcomingMatchesTab extends StatelessWidget {
  final bool isIndiaOnly;

  UpcomingMatchesTab({this.isIndiaOnly = true});

  Future<List<dynamic>> fetchUpcomingMatches() async {
    final response = await http.get(Uri.parse(''));

    if (response.statusCode == 200) {
      List<dynamic> matches = json.decode(response.body)['matches'];
      if (isIndiaOnly) {
        return matches.where((match) => match['team']['name'] == 'India').toList();
      }
      return matches;
    } else {
      throw Exception('Failed to load upcoming matches');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchUpcomingMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No upcoming matches available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var match = snapshot.data![index];
              return ListTile(
                title: Text(match['title']),
                subtitle: Text('Date: ${match['scheduled']}'),
              );
            },
          );
        }
      },
    );
  }
}
