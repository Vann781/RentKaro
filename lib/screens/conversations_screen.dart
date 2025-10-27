// lib/screens/conversations_screen.dart

import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../services/conversation_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart'; // We'll navigate to this

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ConversationService _conversationService = ConversationService();
  final AuthService _authService = AuthService();
  Future<List<Conversation>>? _conversationsFuture;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    // We need the current user's ID to parse the participant list
    final userId = await _authService.getUserId();
    if (userId == null) {
      setState(() {
        _conversationsFuture = Future.error('Not logged in');
      });
      return;
    }
    setState(() {
      _currentUserId = userId;
      _conversationsFuture = _conversationService.getMyConversations().then(
            (jsonList) => jsonList.map((json) {
          // Pass the currentUserId to the parser
          return Conversation.fromJson(json, _currentUserId!);
        }).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: FutureBuilder<List<Conversation>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('Error: ${snapshot.error ?? 'Could not load chats.'}'));
            }

            // 3. No Data State
            final conversations = snapshot.data!;
            if (conversations.isEmpty) {
              return const Center(
                child: Text(
                  'You have no chats yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // 4. Success State: Show the list
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                return _buildConversationTile(convo);
              },
            );
          },
        ),
      ),
    );
  }

  // --- NEW: Conversation List Tile ---
  Widget _buildConversationTile(Conversation convo) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(convo.itemImageUrl),
          ),
          title: Text(
            convo.participantName, // The *other* person's name
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            convo.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            // Simple time formatting (e.g., "10:30 AM" or "Oct 26")
            TimeOfDay.fromDateTime(convo.lastMessageAt).format(context),
          ),
          onTap: () {
            // Open the chat screen for this conversation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  // Pass the CONVERSATION ID and the OTHER person's name
                  conversationId: convo.id,
                  participantName: convo.participantName,
                ),
              ),
            ).then((_) {
              // When we come back from the chat, refresh the list
              _loadConversations();
            });
          },
        ),
        const Divider(height: 0, indent: 80, endIndent: 16),
      ],
    );
  }
}