// lib/services/chat_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  // !! UPDATE THIS with your backend's IP address !!
  // final String _serverUrl = "http://192.168.76.14:5000";
  final String _serverUrl = "https://rentkaro-api.onrender.com";

  IO.Socket? _socket;

  // Connect to the socket server
  void connect(String roomId) {
    try {
      // 1. Initialize the socket
      _socket = IO.io(_serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      // 2. Connect
      _socket!.connect();

      // 3. Listen for connection
      _socket!.onConnect((_) {
        print('Socket connected: ${_socket!.id}');
        // 4. Join the specific item's chat room
        _socket!.emit('join_room', roomId);
      });

      // Handle connection errors
      _socket!.onConnectError((data) {
        print('Socket Connection Error: $data');
      });

      _socket!.onError((data) {
        print('Socket Error: $data');
      });

    } catch (e) {
      print('Error connecting to socket: $e');
    }
  }

  // Send a message
  void sendMessage(String roomId, String senderId, String content) {
    if (_socket == null || !_socket!.connected) {
      print('Socket not connected. Cannot send message.');
      return;
    }

    // This is the 'send_message' event your backend is listening for
    _socket!.emit('send_message', {
      // 'roomId': roomId,
      'conversationId': roomId,
      'senderId': senderId,
      'content': content,
    });
  }

  // Listen for incoming messages
  // We pass a 'handler' (a function) from the ChatScreen to this service.
  void listenForMessages(Function(Map<String, dynamic>) handler) {
    if (_socket == null) return;

    // This is the 'receive_message' event your backend sends
    _socket!.on('receive_message', (data) {
      handler(data);
    });
  }

  // Disconnect from the socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      print('Socket disconnected.');
    }
  }
}