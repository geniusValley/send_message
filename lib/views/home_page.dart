import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../models/group_model.dart';

class HomePage extends StatelessWidget {
  final HomeController _controller = HomeController();

  HomePage({super.key});

  void _fetchGroups() async {
    final groups = await _controller.fetchGroups();
    print('Fetched groups: $groups');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: _fetchGroups, child: Text('Fetch Groups')),
          ],
        ),
      ),
    );
  }
}
