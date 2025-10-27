// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Core FCM package

class AuthService {
  // !! Make sure this is your Wi-Fi IP Address !!
  final String _baseUrl = "http://192.168.76.14:5000";

  static const String _tokenKey = 'authToken';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _profilePicKey = 'profilePicUrl';


  // --- getters for uername and dp ---
  // Getters for use in ProfileScreen
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String?> getProfilePicUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePicKey);
  }

// Private Setters (called during login)
  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<void> _saveProfilePicUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePicKey, url);
  }


  // --- FCM LOGIC (NEW) ---

  // 1. Sends the token to the backend route /api/auth/fcmtoken
  Future<void> _sendFcmTokenToBackend(String token, String? userId) async {
    if (userId == null) return;

    final authToken = await getToken();
    if (authToken == null) return;

    // This URL corresponds to the PUT /api/auth/fcmtoken route we defined
    final String url = "$_baseUrl/api/auth/fcmtoken";

    try {
      await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // Authentication header is required by the protect middleware
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );
      print("FCM Token sent successfully to backend.");
    } catch (e) {
      print('Failed to send token to backend: $e');
    }
  }

  Future<bool> uploadProfilePicture(File imageFile) async {
    final String? token = await getToken();
    if (token == null) return false;

    final String url = "$_baseUrl/api/auth/profilepic"; // New backend route

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar', // Field name for the image
          imageFile.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Profile picture uploaded successfully!');
        return true;
      } else {
        print('Failed to upload profile picture: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      return false;
    }
  }

  // 2. Gets the token from Firebase and calls the sender function
  Future<String?> getAndSaveFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print("FCM Token found: $token");

        final userId = await getUserId();
        // Send the token to the backend immediately
        await _sendFcmTokenToBackend(token, userId);
        return token;
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
    return null;
  }
  // --- END FCM LOGIC ---

  // --- STANDARD AUTH FUNCTIONS ---

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_tokenKey);
  //   await prefs.remove(_userIdKey);
  // }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey); // <-- ADDED
    await prefs.remove(_profilePicKey); // <-- ADDED
  }
  // --- Signup (Unchanged) ---
  Future<bool> signup(
      String name, String username, String email, String password) async {
    final String url = "$_baseUrl/api/auth/signup";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        print("Signup successful!");
        return true;
      } else {
        print("Signup failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error during signup: $e");
      return false;
    }
  }


  // --- Login (UPDATED) ---
  Future<String?> login(String email, String password) async {
    final String url = "$_baseUrl/api/auth/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        String? token = responseData['token'];
        String? userId = responseData['user']?['id'];
        String? username = responseData['user']?['username'];
        String? profilePicUrl = responseData['user']?['profilePicUrl'];

        if (token != null && userId != null) {
          await _saveToken(token);
          await _saveUserId(userId);
          if (username != null) await _saveUsername(username); // <-- SAVE USERNAME
          if (profilePicUrl != null) await _saveProfilePicUrl(profilePicUrl); // <-- SAVE DP URL
          return token;
        }

        return null;
      } else {
        print("Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }
}