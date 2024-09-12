import 'package:flutter/material.dart';
import '../widgets/live_scores_tab.dart';
import '../widgets/previous_matches_tab.dart';
import '../widgets/upcoming_matches_tab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Live Scores'),
            Tab(text: 'Previous Matches'),
            Tab(text: 'Upcoming Matches'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LiveScoresTab(),
          PreviousMatchesTab(),
          UpcomingMatchesTab(),
        ],
      ),
    );
  }
}
