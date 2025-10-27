// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../services/conversation_service.dart'; // <-- NEW IMPORT

// --- (ChatMessage class is unchanged) ---
class ChatMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatScreen extends StatefulWidget {
  // --- UPDATED PARAMETERS ---
  final String conversationId;
  final String participantName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For auto-scrolling
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ConversationService _convoService = ConversationService(); // <-- NEW

  final List<ChatMessage> _messages = [];
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
  }

  Future<void> _loadUserAndMessages() async {
    final userId = await _authService.getUserId();
    if (userId == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // 1. Fetch old messages
    final messagesJson = await _convoService.getMessages(widget.conversationId);

    // --- THIS IS THE FIX ---
    final List<ChatMessage> oldMessages = messagesJson.map((json) {
      // We now expect 'sender' to be a simple String ID
      final senderId = json['sender'] as String? ?? 'unknown_sender';
      return ChatMessage(
        senderId: senderId,
        content: json['content'] ?? '',
        timestamp: DateTime.parse(json['createdAt']),
        isMe: senderId == userId,
      );
    }).toList();
    // --- END FIX ---

    if (!mounted) return;

    setState(() {
      _currentUserId = userId;
      _messages.addAll(oldMessages); // Load history
      _isLoading = false;
    });

    // 2. Connect to the socket
    _chatService.connect(widget.conversationId);

    // 3. Listen for new messages (this logic was already correct)
    _chatService.listenForMessages((data) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              senderId: data['senderId'],
              content: data['content'],
              timestamp: DateTime.parse(data['createdAt']),
              isMe: data['senderId'] == _currentUserId,
            ),
          );
        });
        _scrollToBottom(); // Auto-scroll on new message
      }
    });

    // Scroll to bottom after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.disconnect();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _currentUserId == null) {
      return;
    }

    _chatService.sendMessage(
      widget.conversationId,
      _currentUserId!,
      content,
    );

    // Add our own message to the list (backend will confirm)
    setState(() {
      _messages.add(
        ChatMessage(
          senderId: _currentUserId!,
          content: content,
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.participantName}'), // Use new param
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.blue.shade600],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach controller
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // --- (Input Bar is unchanged) ---
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0).copyWith(bottom: 16.0), // Better padding
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              ),
              onSubmitted: (_) => _sendMessage(), // Send on enter
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  // --- (Message Bubble is unchanged) ---
  Widget _buildMessageBubble(ChatMessage message) {
    final bool isMe = message.isMe;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16.0),
              topRight: const Radius.circular(16.0),
              bottomLeft: isMe ? const Radius.circular(16.0) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16.0),
            ),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}