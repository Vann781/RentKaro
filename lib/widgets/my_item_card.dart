// lib/widgets/my_item_card.dart

import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class MyItemCard extends StatefulWidget {
  final Item item;
  final Function onStatusToggled;

  const MyItemCard({
    super.key,
    required this.item,
    required this.onStatusToggled,
  });

  @override
  State<MyItemCard> createState() => _MyItemCardState();
}

class _MyItemCardState extends State<MyItemCard> {
  final ItemService _itemService = ItemService();
  bool _isToggling = false;

  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.item.isAvailable;
  }

  // --- UPDATED TOGGLE STATUS FUNCTION ---
  Future<void> _toggleStatus() async {
    setState(() {
      _isToggling = true;
    });

    final newStatus = !_isAvailable; // Calculate the desired NEW status (true or false)

    // Send the NEW status to the API.
    // The service handles the HTTP request body format correctly.
    final success = await _itemService.toggleItemStatus(
      widget.item.id,
      newStatus,
    );

    if (mounted) {
      setState(() {
        _isToggling = false;
      });

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Item Relisted!' : 'Item Unlisted.'),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );

        // --- CRITICAL REFRESH LOGIC ---
        // If UNLISTED (newStatus is false), we MUST force the parent list to reload.
        if (!newStatus) {
          widget.onStatusToggled();
          // We do NOT update the local _isAvailable state because the widget will be disposed
          // and replaced by the list reload.
        } else {
          // If RELISTED (newStatus is true), we update local state for instant feedback.
          setState(() {
            _isAvailable = newStatus;
          });
        }
        // --- END CRITICAL REFRESH LOGIC ---

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update item status. Check API connectivity.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Image ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),

                // --- Details ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '\$${widget.item.pricePerDay.toStringAsFixed(2)} / day',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // --- Status Display ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _isAvailable ? 'LISTED' : 'UNLISTED',
                          style: TextStyle(
                            color: _isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            // --- Toggle Button ---
            Align(
              alignment: Alignment.centerRight,
              child: _isToggling
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : TextButton.icon(
                onPressed: _toggleStatus,
                icon: Icon(
                  _isAvailable ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  color: _isAvailable ? Colors.red : Colors.green,
                ),
                label: Text(
                  _isAvailable ? 'Unlist Item' : 'Relist Item',
                  style: TextStyle(
                    color: _isAvailable ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}