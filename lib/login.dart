import 'package:flutter/material.dart';
import 'package:hello_world/config/app_constants.dart';
import 'package:hello_world/dashboard.dart';
import 'package:hello_world/services/user_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  Timer? _autoNavigationTimer; // Add timer variable

  @override
  void initState() {
    super.initState();
    // Predefine username and password for testing/demo purposes
    _usernameController.text = 'user.podlatihan';
    _passwordController.text = 'P@\$\$w0rdke2025';
  }

  @override
  void dispose() {
    // Cancel timer if it's active when widget is disposed
    _autoNavigationTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // First, trigger validation and check if the form is valid
    print('Login button pressed');
    print('Username: ${_usernameController.text}');
    print('Password: ${_passwordController.text}');

    bool isValid = _formKey.currentState!.validate();
    print('Form is valid: $isValid');

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      String username = _usernameController.text;
      String password = _passwordController.text;

      try {
        // Call the login API
        bool loginSuccess = await _callLoginAPI(username, password);

        setState(() {
          _isLoading = false;
        });

        if (loginSuccess) {
          // Show success dialog before navigating to dashboard
          _showSuccessDialog();
        } else {
          // Show error if login failed
          _showErrorMessage('Login failed. Please check your credentials.');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Show error if API call failed
        _showErrorMessage('Network error. Please try again.');
        print('Login error: $e');
      }
    } else {
      // Show error message if validation fails
      print('Validation failed - showing snackbar');
      _showErrorMessage('Please fix the errors in the form');
    }
  }

  Future<bool> _callLoginAPI(String username, String password) async {
    try {
      // Step 1: OpenID Connect Token Request
      print('Step 1: Calling OpenID Connect...');
      final openIdResponse = await http.post(
        Uri.parse(AppConstants.openIdConnect),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': AppConstants.clientId,
          'client_secret': AppConstants.clientSecret,
          'username': username,
          'password': password,
        },
      );

      print('OpenID Connect Response Status: ${openIdResponse.statusCode}');
      print('OpenID Connect Response Body: ${openIdResponse.body}');

      if (openIdResponse.statusCode != 200) {
        print('OpenID Connect failed');
        return false;
      }

      final openIdData = json.decode(openIdResponse.body);
      String? accessToken = openIdData['access_token'];

      if (accessToken == null) {
        print('No access token received');
        return false;
      }

      // Step 2: Token Introspection
      print('Step 2: Calling Token Introspection...');
      final introspectResponse = await http.post(
        Uri.parse(AppConstants.introSpect),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': accessToken,
          'client_id': AppConstants.clientId,
          'client_secret': AppConstants.clientSecret,
        },
      );

      print('Introspect Response Status: ${introspectResponse.statusCode}');
      print('Introspect Response Body: ${introspectResponse.body}');

      if (introspectResponse.statusCode != 200) {
        print('Token introspection failed');
        return false;
      }

      final introspectData = json.decode(introspectResponse.body);
      bool? tokenActive = introspectData['active'];
      final sub = introspectData['sub'];

      if (tokenActive != true) {
        print('Token is not active');
        return false;
      }

      // Step 3: SSO Login
      print('Step 3: Calling SSO Login...');
      final ssoResponse = await http.get(
        Uri.parse('${AppConstants.loginSso}?sso_id=$sub'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('SSO Login Response Status: ${ssoResponse.statusCode}');
      print('SSO Login Response Body: ${ssoResponse.body}');

      if (ssoResponse.statusCode == 200) {
        final ssoData = json.decode(ssoResponse.body);

        // Store user data and tokens securely using SharedPreferences
        await UserStorageService.saveAuthenticationData(
          accessToken: accessToken,
          refreshToken: openIdData['refresh_token'], // if available
          userData: ssoData,
        );

        print('Login successful! User data: ${ssoData.toString()}');
        print('All three API calls completed successfully.');

        // Optional: Print stored data for debugging
        final storedData = await UserStorageService.getAllStoredData();
        print('Stored authentication data: $storedData');

        return true;
      } else {
        print('SSO Login failed');
        return false;
      }
    } catch (e) {
      print('API call error: $e');
      rethrow; // Re-throw to be caught by the calling method
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'Login Successful!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back! You have successfully logged in.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Redirecting to dashboard...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _navigateToDashboard();
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Auto-close dialog and navigate after 3 seconds with proper checks
    _autoNavigationTimer = Timer(Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    // Cancel the timer if navigation is triggered manually
    _autoNavigationTimer?.cancel();

    // Check if widget is still mounted before navigation
    if (mounted) {
      // Close dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close dialog
      }
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    // Username can contain letters, numbers, and symbols
    // Check minimum length
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    // Check maximum length (optional)
    if (value.length > 50) {
      return 'Username must be less than 50 characters';
    }
    // Check for invalid characters (optional - you can remove this if you want to allow all characters)
    // This regex allows alphanumeric characters, underscore, dash, dot, and most symbols
    if (!RegExp(
      r'^[a-zA-Z0-9._@#$%^&*()+=\-!?<>{}[\]|\\/:;,~`]+$',
    ).hasMatch(value)) {
      return 'Username contains invalid characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft light grey background
      // appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 5,
                child: Image.asset('assets/images/flutter.png'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your username',
                ),
                validator: _validateUsername,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: _validatePassword,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
