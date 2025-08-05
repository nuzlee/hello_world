import 'package:flutter/material.dart';
import 'package:hello_world/screens/home.dart';
import 'package:hello_world/screens/profile.dart';
import 'package:hello_world/screens/settings.dart';
import 'package:hello_world/services/user_storage_service.dart';
import 'package:hello_world/login.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isLoadingUserData = true;
  String? _penggunaNama; // Add variable to store user name

  final List<Widget> _pages = [HomeScreen(), ProfileScreen(), SettingsScreen()];

  final List<String> _title = ['Home', 'Profile', 'Settings'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserStorageService.getUserData();
      final accessToken = await UserStorageService.getAccessToken();
      final loginTime = await UserStorageService.getLoginTime();

      setState(() {
        _userData = userData;
        // Extract pengguna_nama from user data
        _penggunaNama = userData?['data']?['pengguna_nama']?.toString();
        _isLoadingUserData = false;
      });

      print('Loaded user data: ${userData?['data']?['pengguna_nama']}');
      print('Pengguna nama: $_penggunaNama');
      print('Access token: ${accessToken?.substring(0, 20)}...');
      print('Login time: $loginTime');
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  void _logout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Clear stored authentication data
      await UserStorageService.clearAllData();

      // Navigate back to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  void _showUserInfo() async {
    final allData = await UserStorageService.getAllStoredData();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Stored User Data'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Login Status: ${allData['is_logged_in']}'),
                  SizedBox(height: 8),
                  Text('Login Time: ${allData['login_time']}'),
                  SizedBox(height: 8),
                  Text(
                    'Access Token: ${allData['access_token']?.toString().substring(0, 30)}...',
                  ),
                  SizedBox(height: 8),
                  Text('User Data: ${allData['user_data']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title[_currentIndex].toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!_isLoadingUserData && _penggunaNama != null)
              Text(
                'Welcome, $_penggunaNama',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // User info button
          if (!_isLoadingUserData && _userData != null)
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _showUserInfo(),
              tooltip: 'User Info',
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
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
