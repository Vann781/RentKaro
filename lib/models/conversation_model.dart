// lib/models/conversation_model.dart

class Conversation {
  final String id;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String participantName;
  final String participantId;
  final String itemImageUrl;
  final String itemName;

  Conversation({
    required this.id,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.participantName,
    required this.participantId,
    required this.itemImageUrl,
    required this.itemName,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {

    // Find the *other* participant's details
    String pName = 'Other User';
    String pId = '';
    final participants = json['participants'] as List<dynamic>? ?? [];

    for (var participant in participants) {
      if (participant['_id'] != currentUserId) {
        pName = participant['username'] ?? 'Other User';
        pId = participant['_id'] ?? '';
        break;
      }
    }

    return Conversation(
      id: json['_id'] ?? '',
      lastMessage: json['lastMessage'] ?? '...',
      lastMessageAt: DateTime.tryParse(json['lastMessageAt'] ?? '') ?? DateTime.now(),
      participantName: pName,
      participantId: pId,
      itemImageUrl: json['item']?['imageUrl'] ?? 'https://via.placeholder.com/150',
      itemName: json['item']?['name'] ?? 'Item',
    );
  }
}