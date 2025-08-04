import 'package:flutter/material.dart';
import 'package:hello_world/screens/home.dart';
import 'package:hello_world/screens/profile.dart';
import 'package:hello_world/screens/settings.dart';

class DashboardPage extends StatefulWidget {
  final String email;
  
  const DashboardPage({Key? key, required this.email}) : super(key: key);
  
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomeScreen(), ProfileScreen(), SettingsScreen()];

  final List<String> _title = ['Home Page', 'Profile Page', 'Settings Page'];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(_title[_currentIndex].toString())),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap:
            (index) => setState(() {
              _currentIndex = index;
            }),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
