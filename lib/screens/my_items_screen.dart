// lib/screens/my_items_screen.dart

import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';
import '../widgets/my_item_card.dart'; // <-- USE NEW WIDGET

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  final ItemService _itemService = ItemService();
  late Future<List<Item>> _myItemsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the items when the screen loads
    _myItemsFuture = _itemService.getMyItems();
  }

  // Function to refresh the list
  Future<void> _refreshItems() async {
    setState(() {
      _myItemsFuture = _itemService.getMyItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listed Items'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: FutureBuilder<List<Item>>(
          future: _myItemsFuture,
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // 3. No Data State
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'You haven\'t listed any items yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // 4. Success State: Show the list
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                // --- USE NEW CARD ---
                return MyItemCard(
                  item: item,
                  onStatusToggled: _refreshItems, // Pass refresh function
                );
              },
            );
          },
        ),
      ),
    );
  }
}