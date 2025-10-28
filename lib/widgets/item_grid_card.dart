// lib/widgets/item_grid_card.dart

import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../screens/chat_screen.dart';
import '../screens/item_detail_screen.dart';

// Helper function to format the distance
String _formatDistance(double distanceInMeters) {
  if (distanceInMeters < 1000) {
    return '${distanceInMeters.toStringAsFixed(0)} m away';
  } else {
    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(1)} km away';
  }
}

class ItemGridCard extends StatelessWidget {
  final Item item;
  const ItemGridCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(item: item),

          ),
        );
      },
      child: Card(
        elevation: 3.0,
        clipBehavior: Clip.antiAlias, // For rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Item Image ---
            Image.network(
              item.imageUrl,
              height: 120, // Fixed height for grid
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 40),
                );
              },
            ),
      
            // --- Item Details ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title ---
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
      
                  // --- Owner & Distance ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                        child: Text(
                          item.ownerUsername.isNotEmpty ? item.ownerUsername[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          "${item.ownerUsername} • ${_formatDistance(item.distance)}",
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
      
                  // --- Price ---
                  Row(
                    children: [
                      Text(
                        '${item.pricePerDay.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Text(
                        ' / day',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}