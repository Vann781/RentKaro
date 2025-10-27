// lib/services/conversation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/item_model.dart'; // We'll need this soon

class ConversationService {
  // !! Make sure this is your Wi-Fi IP Address !!
  final String _baseUrl = "http://192.168.76.14:5000"; // <-- UPDATE THIS
  final AuthService _authService = AuthService();

  // --- 1. Start or Find a Conversation ---
  // Returns the ID of the conversation
  Future<String?> startConversation(String itemId, String ownerId) async {
    final String? token = await _authService.getToken();
    if (token == null) {
      print('No token, cannot start chat.');
      return null;
    }

    final String url = "$_baseUrl/api/conversations/start";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'itemId': itemId,
          'ownerId': ownerId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['_id']; // Return the conversation ID
      } else {
        print('Failed to start conversation: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error starting conversation: $e');
      return null;
    }
  }

  // --- 2. Get All of the User's Conversations ---
  // (We'll build the model for this in a bit)
  Future<List<dynamic>> getMyConversations() async {
    final String? token = await _authService.getToken();
    if (token == null) return [];

    final String url = "$_baseUrl/api/conversations/my";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Failed to get conversations: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // --- 3. Get All Messages for a Conversation ---
  // (We'll use this in the ChatScreen later)
  Future<List<dynamic>> getMessages(String conversationId) async {
    final String? token = await _authService.getToken();
    if (token == null) return [];

    final String url = "$_baseUrl/api/conversations/$conversationId/messages";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Failed to get messages: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }
}