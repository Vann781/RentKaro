// // lib/screens/main_screen.dart
//
// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'conversations_screen.dart'; // <-- NEW IMPORT
// import 'profile_screen.dart';
// import 'login_screen.dart';
// import 'add_item_screen.dart';
// import '../services/auth_service.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//   final AuthService _authService = AuthService();
//
//   // --- UPDATED: Added ConversationsScreen ---
//   static const List<Widget> _screens = [
//     HomeScreen(),
//     ConversationsScreen(), // <-- NEW
//     ProfileScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   void _handleLogout() async {
//     // ... (this function is unchanged)
//     await _authService.logout();
//     if (mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//             (Route<dynamic> route) => false,
//       );
//     }
//   }
//
//   // --- Search Bar Widget (unchanged) ---
//   Widget _buildSearchBar(BuildContext context) {
//     return Container(
//       height: 40,
//       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: GestureDetector(
//         onTap: () {
//           // TODO: Navigate to a Search Screen
//           print("Search bar tapped");
//         },
//         child: Row(
//           children: [
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10.0),
//               child: Icon(Icons.search, color: Colors.grey),
//             ),
//             Text(
//               'Search for items...',
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- NEW: Function to get the correct AppBar title ---
//   Widget _buildAppBarTitle(BuildContext context) {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildSearchBar(context); // Home
//       case 1:
//         return const Text('My Chats'); // Chats
//       case 2:
//         return const Text('Your Profile'); // Profile
//       default:
//         return _buildSearchBar(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Theme.of(context).primaryColor, Colors.blue.shade600],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//           ),
//         ),
//         // --- UPDATED: Use the new title function ---
//         title: _buildAppBarTitle(context),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _handleLogout,
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _screens,
//       ),
//
//       // --- UPDATED: FAB only shows on Home (index 0) ---
//       floatingActionButton: _selectedIndex == 0
//           ? FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddItemScreen()),
//           );
//         },
//         child: const Icon(Icons.add),
//       )
//           : null,
//
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           // --- NEW: Chats Tab ---
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble_outline),
//             label: 'Chats',
//           ),
//           // ---
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'conversations_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'add_item_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  static const List<Widget> _screens = [
    HomeScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- LOGOUT FUNCTION IS KEPT, BUT NO LONGER ON THE MAIN SCREEN UI ---
  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  // --- Search Bar Widget (unchanged) ---
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          print("Search bar tapped");
        },
        child: const Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            Text(
              'Search for items...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: Function to get the correct AppBar title/widget for non-home screens ---
  Widget _buildAppBarTitle(BuildContext context) {
    switch (_selectedIndex) {
      case 1:
        return const Text('My Chats');
      case 2:
        return const Text('Your Profile');
      default:
        return Container();
    }
  }


  PreferredSizeWidget _buildCustomHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,

        // --- 1. Top Row (Logo/Title and Actions) ---
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- LOGO/TITLE ---
              // Show Logo only on Home tab (index 0)
              if (_selectedIndex == 0)
                SizedBox(
                  height: 35,
                  child: Image.asset(
                    'assets/logo/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // This ensures you still see "RentKaro" if the image path is wrong
                      return const Text("RentKaro", style: TextStyle(color: Colors.white));
                    },
                  ),
                )
              // Show title on other tabs
              else
                _buildAppBarTitle(context),

              // --- ACTION: NOTIFICATION ICON ---
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  // TODO: Navigate to the Notifications page
                  print("Notifications tapped");
                },
              ),
            ],
          ),
        ),

        // --- 2. Bottom Area (Search Bar) ---
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Only show search bar on Home screen (index 0)
            if (_selectedIndex == 0)
              _buildSearchBar(context)
            // Add spacing on other screens to keep the bottom edge consistent
            else
              const SizedBox(height: 16.0),

            const SizedBox(height: 12.0), // Spacing below search bar/tabs
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomHeader(context),

      // --- Body ---
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // --- FAB (unchanged) ---
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,

      // --- Bottom Navigation Bar (unchanged) ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Chats Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          // Profile Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
      ),
    );
  }
}