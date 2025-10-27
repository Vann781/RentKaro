// // lib/screens/home_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import '../models/item_model.dart';
// import '../services/location_service.dart';
// import '../services/item_service.dart';
// import 'package:location/location.dart';
// import '../widgets/item_grid_card.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   // Services
//   final LocationService _locationService = LocationService();
//   final ItemService _itemService = ItemService();
//
//   // State
//   String _loadingMessage = 'Getting your location...';
//   bool _isLoading = true;
//   LocationData? _userLocation;
//   List<Item> _items = [];
//
//   // --- Dummy banners ---
//   final List<String> _bannerImages = [
//     'https://via.placeholder.com/600x250.png/FF6F00/FFFFFF?text=Rent+Sports+Gear',
//     'https://via.placeholder.com/600x250.png/0A1F44/FFFFFF?text=Electronics+Deals', // Using Navy color
//     'https://via.placeholder.com/600x250.png/FFA000/0A1F44?text=Tools+for+Your+Project', // Using Dark Yellow
//   ];
//   int _currentBanner = 0;
//   // ---
//
//   // --- Category Data ---
//   final List<String> _categoriesList = [
//     'All', 'Tools', 'Electronics', 'Sports', 'Vehicles', 'Other'
//   ];
//   // ---
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchLocationAndItems();
//   }
//
//   Future<void> _fetchLocationAndItems() async {
//     setState(() { _isLoading = true; _loadingMessage = 'Getting your location...'; });
//     try {
//       final locationData = await _locationService.getUserLocation();
//       if (locationData != null && mounted) {
//         setState(() { _userLocation = locationData; _loadingMessage = 'Finding nearby items...'; });
//         final List<Item> fetchedItems = await _itemService.getItemsNearby(
//           locationData.latitude!, locationData.longitude!,
//         );
//         if (mounted) { setState(() { _items = fetchedItems; }); }
//       } else if (mounted) {
//         setState(() { _loadingMessage = 'Location permission denied. Cannot find items.'; });
//       }
//     } catch (e) { print("Failed to get location or items: $e"); }
//     finally {
//       if (mounted) { setState(() { _isLoading = false; }); }
//     }
//   }
//
//   // --- Category Row Widget ---
//   Widget _buildCategoryRow() {
//     return Container(
//       color: Colors.white, // White strip for categories
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             const SizedBox(width: 12),
//             ..._categoriesList.map((category) => _buildCategoryChip(category)).toList(),
//             const SizedBox(width: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- Category Chip Widget (Styling using new theme colors) ---
//   Widget _buildCategoryChip(String category) {
//     // You can add state logic here later to highlight the selected category
//     final isSelected = category == 'All';
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ActionChip(
//         label: Text(
//             category,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Colors.white : Theme.of(context).primaryColor,
//             )
//         ),
//         backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//         onPressed: () {
//           // TODO: Implement filtering logic here
//           print('Category selected: $category');
//         },
//       ),
//     );
//   }
//
//   // --- Banner Carousel Widget (Styling using new theme colors) ---
//   Widget _buildOfferCarousel() {
//     return CarouselSlider(
//       options: CarouselOptions(
//         height: 150.0,
//         autoPlay: true,
//         autoPlayInterval: const Duration(seconds: 4),
//         viewportFraction: 0.9,
//         enlargeCenterPage: true,
//         onPageChanged: (index, reason) {
//           setState(() { _currentBanner = index; });
//         },
//       ),
//       items: _bannerImages.map((i) {
//         return Builder(
//           builder: (BuildContext context) {
//             return Container(
//               width: MediaQuery.of(context).size.width,
//               margin: const EdgeInsets.symmetric(horizontal: 5.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12.0),
//                 child: Image.network(i, fit: BoxFit.cover),
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   // --- Section Title Widget ---
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Theme.of(context).colorScheme.background, // Light Grey background color
//
//       child: RefreshIndicator(
//         onRefresh: _fetchLocationAndItems,
//         child: CustomScrollView(
//           slivers: [
//             // --- 1. Category Row (Fixed Content) ---
//             SliverToBoxAdapter(
//               child: _buildCategoryRow(), // Your new category navigation
//             ),
//
//             // Loading state
//             if (_isLoading)
//               SliverFillRemaining(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const CircularProgressIndicator(),
//                       const SizedBox(height: 16),
//                       Text(_loadingMessage),
//                     ],
//                   ),
//                 ),
//               ),
//
//             // Data loaded state
//             if (!_isLoading) ...[
//               // 2. Banners
//               const SliverToBoxAdapter(child: SizedBox(height: 12)),
//               SliverToBoxAdapter(
//                 child: _buildOfferCarousel(),
//               ),
//
//               // 3. Title
//               SliverToBoxAdapter(
//                 child: _buildSectionTitle('Nearby Items'),
//               ),
//
//               // 4. Items Grid
//               if (_items.isEmpty)
//                 SliverFillRemaining(
//                   child: Center(
//                     child: Text(
//                       'No items found nearby.\nTry again later!',
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                   ),
//                 )
//               else
//                 SliverPadding(
//                   padding: const EdgeInsets.all(12.0),
//                   sliver: SliverGrid(
//                     gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 12.0,
//                       mainAxisSpacing: 12.0,
//                       childAspectRatio: 0.65,
//                     ),
//                     delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                         final item = _items[index];
//                         return ItemGridCard(item: item);
//                       },
//                       childCount: _items.length,
//                     ),
//                   ),
//                 ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/item_model.dart';
import '../services/location_service.dart';
import '../services/item_service.dart';
import 'package:location/location.dart';
import '../widgets/item_grid_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services (unchanged)
  final LocationService _locationService = LocationService();
  final ItemService _itemService = ItemService();

  // State (unchanged)
  String _loadingMessage = 'Getting your location...';
  bool _isLoading = true;
  LocationData? _userLocation;
  List<Item> _items = [];

  // --- Dummy banners --- (unchanged)
  final List<String> _bannerImages = [
    'https://via.placeholder.com/600x250.png/FF6F00/FFFFFF?text=Rent+Sports+Gear',
    'https://via.placeholder.com/600x250.png/0A1F44/FFFFFF?text=Electronics+Deals',
    'https://via.placeholder.com/600x250.png/FFA000/0A1F44?text=Tools+for+Your+Project',
  ];
  int _currentBanner = 0;

  // --- Category Data --- (unchanged)
  final List<String> _categoriesList = [
    'All', 'Tools', 'Electronics', 'Sports', 'Vehicles', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocationAndItems();
  }

  Future<void> _fetchLocationAndItems() async {
    setState(() { _isLoading = true; _loadingMessage = 'Getting your location...'; });
    try {
      final locationData = await _locationService.getUserLocation();
      if (locationData != null && mounted) {
        setState(() { _userLocation = locationData; _loadingMessage = 'Finding nearby items...'; });
        final List<Item> fetchedItems = await _itemService.getItemsNearby(
          locationData.latitude!, locationData.longitude!,
        );
        if (mounted) { setState(() { _items = fetchedItems; }); }
      } else if (mounted) {
        setState(() { _loadingMessage = 'Location permission denied. Cannot find items.'; });
      }
    } catch (e) { print("Failed to get location or items: $e"); }
    finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  // --- Category Row Widget ---
  Widget _buildCategoryRow() {
    return Container(
      color: Colors.white, // White strip for categories
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 12),
            ..._categoriesList.map((category) => _buildCategoryChip(category)).toList(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // --- Category Chip Widget (unchanged) ---
  Widget _buildCategoryChip(String category) {
    final isSelected = category == 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            )
        ),
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        onPressed: () {
          print('Category selected: $category');
        },
      ),
    );
  }

  // --- Banner Carousel Widget (unchanged) ---
  Widget _buildOfferCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() { _currentBanner = index; });
        },
      ),
      items: _bannerImages.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(i, fit: BoxFit.cover),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // --- Section Title Widget (unchanged) ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background, // Light Grey background color

      child: RefreshIndicator(
        onRefresh: _fetchLocationAndItems,
        child: CustomScrollView(
          // --- FIX: The CustomScrollView now starts with the Category Row ---
          slivers: [
            // --- 1. Category Row ---
            SliverToBoxAdapter(
              child: _buildCategoryRow(),
            ),

            // Loading state
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_loadingMessage),
                    ],
                  ),
                ),
              ),

            // Data loaded state
            if (!_isLoading) ...[
              // 2. Banners
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: _buildOfferCarousel(),
              ),

              // 3. Title
              SliverToBoxAdapter(
                child: _buildSectionTitle('Nearby Items'),
              ),

              // 4. Items Grid
              if (_items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No items found nearby.\nTry again later!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(12.0),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final item = _items[index];
                        return ItemGridCard(item: item);
                      },
                      childCount: _items.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}