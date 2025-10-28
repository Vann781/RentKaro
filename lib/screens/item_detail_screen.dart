import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';
import 'chat_screen.dart';
import '../services/conversation_service.dart'; // For starting chat

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ConversationService _convoService = ConversationService();
  final ItemService _itemService = ItemService();

  // State for Renting and Chat buttons
  bool _isChatLoading = false;
  bool _isRenting = false;

  // State for Date Picker
  DateTime? _startDate;
  DateTime? _endDate;

  // --- CHAT LOGIC ---
  void _handleChatPress() async {
    setState(() {
      _isChatLoading = true;
    });

    try {
      // 1. Start or find the conversation
      final conversationId = await _convoService.startConversation(
        widget.item.id,
        widget.item.ownerId,
      );

      if (conversationId != null && mounted) {
        // 2. Navigate to the chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              participantName: widget.item.ownerUsername,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start chat. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error starting chat: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isChatLoading = false;
        });
      }
    }
  }

  // --- RENTING LOGIC ---
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)), // 1 year limit
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now().add(const Duration(days: 3)),
      ),
      builder: (context, child) {
        // Theme for the date picker dialog
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Navy Blue header
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _startDate = picked.start;
      _endDate = picked.end;

      // Automatically initiate the rental after dates are picked
      await _initiateRentNow();
    }
  }

  Future<void> _initiateRentNow() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date range.')));
      return;
    }

    setState(() { _isRenting = true; });

    final success = await _itemService.rentItem(
      widget.item.id,
      _startDate!.toIso8601String(), // Send ISO strings to backend
      _endDate!.toIso8601String(),
    );

    if (mounted) {
      setState(() { _isRenting = false; });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rental confirmed! Item is now active.'),
            backgroundColor: Colors.green
        ));
        Navigator.pop(context); // Go back to Home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rental failed. Item may be reserved.'),
            backgroundColor: Colors.red
        ));
      }
    }
  }
  // --- END RENTING LOGIC ---


  // --- HELPER WIDGETS ---
  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m away';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km away';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaceholderItem() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(child: Text('Item')),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0).copyWith(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // --- Chat Button ---
          Expanded(
            child: OutlinedButton(
              onPressed: _isChatLoading ? null : _handleChatPress,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: _isChatLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                  : const Text('Chat', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12.0),

          // --- Rent Now Button (Calls Date Picker) ---
          Expanded(
            child: ElevatedButton(
              onPressed: _isRenting ? null : () => _selectDateRange(context), // Calls date picker
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: _isRenting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Rent Now', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
  // --- END HELPER WIDGETS ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. App Bar with Image ---
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.item.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Image.network(
                widget.item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 50),
                  );
                },
              ),
            ),
          ),

          // --- 2. Item Details Section ---
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // -- Price --
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        '${widget.item.pricePerDay.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Text(' / day', style: TextStyle(fontSize: 18.0, color: Colors.grey)),
                    ],
                  ),
                ),

                // -- Owner Info --
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                    child: Text(
                      widget.item.ownerUsername.isNotEmpty ? widget.item.ownerUsername[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: const Text('Listed by', style: TextStyle(color: Colors.grey)),
                  subtitle: Text(
                    widget.item.ownerUsername,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.black),
                  ),
                  trailing: Text(
                    _formatDistance(widget.item.distance),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 24),

                // -- Description --
                _buildSectionTitle('Description'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    widget.item.description,
                    style: const TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 24),

                _buildSectionTitle('Reviews (Coming Soon)'),
                const ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text('4.5 stars'),
                  subtitle: Text('Based on 12 reviews'),
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _buildSectionTitle('More from ${widget.item.ownerUsername} (Coming Soon)'),
                Container(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16.0),
                    children: [
                      _buildPlaceholderItem(),
                      _buildPlaceholderItem(),
                      _buildPlaceholderItem(),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // --- Bottom Buttons ---
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }
}