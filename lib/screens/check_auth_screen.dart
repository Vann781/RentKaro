import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  final AuthService _authService = AuthService();

  // Future that checks for a token
  late final Future<String?> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    // Get the token right when the screen starts
    _authCheckFuture = _authService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authCheckFuture,
      builder: (context, snapshot) {
        // 1. Still loading or checking the token
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a simple loading screen
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Token found (User is logged in)
        // If the token string is NOT null, go to the Main screen.
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // 3. No token found (Go to Login)
        else {
          return const LoginScreen();
        }
      },
    );
  }
}