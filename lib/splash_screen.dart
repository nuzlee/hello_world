import 'package:flutter/material.dart';
import 'package:hello_world/services/user_storage_service.dart';
import 'package:hello_world/login.dart';
import 'package:hello_world/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    // Add a small delay for splash effect
    await Future.delayed(Duration(seconds: 2));

    try {
      // Check if user is logged in
      bool isLoggedIn = await UserStorageService.isLoggedIn();

      if (isLoggedIn) {
        // Check if token is still valid (optional)
        bool tokenExpired = await UserStorageService.isTokenExpired();

        if (tokenExpired) {
          print('Token expired, redirecting to login');
          await UserStorageService.clearAllData();
          _navigateToLogin();
        } else {
          print('User is logged in, redirecting to dashboard');
          _navigateToDashboard();
        }
      } else {
        print('User not logged in, redirecting to login');
        _navigateToLogin();
      }
    } catch (e) {
      print('Error checking authentication status: $e');
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _navigateToDashboard() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => DashboardPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(Icons.flutter_dash, size: 60, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'Hello World',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
