// // lib/screens/profile_screen.dart
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'my_items_screen.dart';
// import 'login_screen.dart';
// import '../services/auth_service.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final AuthService _authService = AuthService();
//   final ImagePicker _picker = ImagePicker();
//
//   // State variables for the profile picture and user info
//   File? _localImageFile;
//   String _currentDpUrl = 'https://via.placeholder.com/150.png?text=DP';
//   String _currentUsername = 'User'; // Default
//   bool _isUploading = false;
//   bool _isLoadingUserData = true; // NEW: To show loader while fetching data
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfileData(); // Fetch data when screen initializes
//   }
//
//   // --- Function to load username and DP URL on startup ---
//   Future<void> _loadUserProfileData() async {
//     final username = await _authService.getUsername();
//     final dpUrl = await _authService.getProfilePicUrl();
//
//     if (mounted) {
//       setState(() {
//         _currentUsername = username ?? 'User';
//         _currentDpUrl = dpUrl ?? 'https://via.placeholder.com/150.png?text=DP';
//         _isLoadingUserData = false;
//       });
//     }
//   }
//
//   // --- Image Selection and Upload Logic ---
//   Future<void> _selectAndUploadImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       final File imageFile = File(pickedFile.path);
//
//       setState(() {
//         _localImageFile = imageFile;
//         _isUploading = true;
//       });
//
//       // Call the service to upload the image
//       final success = await _authService.uploadProfilePicture(imageFile);
//
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
//           );
//           // Reload the data to update _currentDpUrl from local storage
//           await _loadUserProfileData();
//           setState(() {
//             _localImageFile = null; // Clear local file, let network image load new URL
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to upload picture.'), backgroundColor: Colors.red),
//           );
//           setState(() {
//             _localImageFile = null;
//           });
//         }
//       }
//     }
//   }
//
//   // --- Logout Confirmation Dialog Function ---
//   Future<void> _confirmLogout(BuildContext context) async {
//     final bool? shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Confirm Logout'),
//           content: const Text('Are you sure you want to log out?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop(false);
//               },
//             ),
//             TextButton(
//               child: const Text('Logout', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop(true);
//               },
//             ),
//           ],
//         );
//       },
//     );
//
//     if (shouldLogout == true) {
//       await _authService.logout();
//       if (context.mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoadingUserData) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return ListView(
//       padding: const EdgeInsets.all(8.0),
//       children: [
//         // --- PROFILE PICTURE SECTION ---
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20.0),
//           child: Center(
//             child: GestureDetector(
//               onTap: _isUploading ? null : _selectAndUploadImage,
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Theme.of(context).primaryColor,
//                     // Load local file if selected, otherwise load network URL
//                     backgroundImage: _localImageFile != null
//                         ? FileImage(_localImageFile!) as ImageProvider
//                         : NetworkImage(_currentDpUrl),
//                     child: _isUploading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : null,
//                   ),
//                   // Edit Icon
//                   if (!_isUploading)
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.secondary,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         child: const Icon(Icons.edit, color: Colors.white, size: 18),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         // --- USERNAME DISPLAY (DYNAMIC) ---
//         Center(
//           child: Text(
//             _currentUsername, // Display the fetched username
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(height: 20.0),
//
//         const Divider(height: 1),
//
//         // --- "My Listed Items" Button ---
//         ListTile(
//           leading: Icon(
//             Icons.list_alt,
//             color: Theme.of(context).primaryColor,
//           ),
//           title: const Text(
//             'My Listed Items',
//             style: TextStyle(fontSize: 18),
//           ),
//           subtitle: const Text('View and manage your items'),
//           trailing: const Icon(Icons.chevron_right),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const MyItemsScreen()),
//             );
//           },
//         ),
//
//         const Divider(),
//
//         // --- Placeholder for "My Rentals" ---
//         ListTile(
//           leading: Icon(
//             Icons.shopping_bag,
//             color: Colors.grey[600],
//           ),
//           title: const Text(
//             'My Rentals',
//             style: TextStyle(fontSize: 18),
//           ),
//           subtitle: const Text('Items you are currently renting'),
//           trailing: const Icon(Icons.chevron_right),
//           onTap: () {
//             print('My Rentals Tapped');
//           },
//         ),
//
//         const Divider(),
//
//         // --- Placeholder for "Account Settings" ---
//         ListTile(
//           leading: Icon(
//             Icons.settings,
//             color: Colors.grey[600],
//           ),
//           title: const Text(
//             'Account Settings',
//             style: TextStyle(fontSize: 18),
//           ),
//           subtitle: const Text('Update your profile details'),
//           trailing: const Icon(Icons.chevron_right),
//           onTap: () {
//             print('Settings Tapped');
//           },
//         ),
//
//         const Divider(height: 32),
//
//         // --- LOGOUT BUTTON ---
//         ListTile(
//           leading: const Icon(
//             Icons.logout,
//             color: Colors.red,
//           ),
//           title: const Text(
//             'Logout',
//             style: TextStyle(fontSize: 18, color: Colors.red),
//           ),
//           onTap: () => _confirmLogout(context),
//         ),
//       ],
//     );
//   }
// }


// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'my_items_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // State variables
  File? _localImageFile;
  String _currentDpUrl = 'https://via.placeholder.com/150.png?text=DP';
  String _currentUsername = 'User';
  bool _isUploading = false;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    final username = await _authService.getUsername();
    final dpUrl = await _authService.getProfilePicUrl();

    if (mounted) {
      setState(() {
        _currentUsername = username ?? 'User';
        _currentDpUrl = dpUrl ?? 'https://via.placeholder.com/150.png?text=DP';
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _selectAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      setState(() {
        _localImageFile = imageFile;
        _isUploading = true;
      });

      final success = await _authService.uploadProfilePicture(imageFile);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
          );
          await _loadUserProfileData();
          setState(() {
            _localImageFile = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload picture.'), backgroundColor: Colors.red),
          );
          setState(() {
            _localImageFile = null;
          });
        }
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _authService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Center(child: CircularProgressIndicator());
    }

    // Meesho-style: Uses a single ScrollView for the body
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- 1. TOP PROFILE CARD (The Meesho Centerpiece) ---
          Card(
            margin: const EdgeInsets.all(12.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and Edit Icon
                  GestureDetector(
                    onTap: _isUploading ? null : _selectAndUploadImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                          backgroundImage: _localImageFile != null
                              ? FileImage(_localImageFile!) as ImageProvider
                              : NetworkImage(_currentDpUrl),
                          child: _isUploading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                              : null,
                        ),
                        if (!_isUploading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),

                  // Username and Status/Edit Button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUsername,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Active User',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),

                  // Optional: Edit Profile Button
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      print('Navigate to detailed Account Settings');
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- 2. MENU OPTIONS ---
          // My Listed Items
          _buildMenuTile(
            context,
            Icons.list_alt,
            'My Listed Items',
            'View and manage your active listings',
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyItemsScreen()));
            },
          ),

          // My Rentals
          _buildMenuTile(
            context,
            Icons.shopping_bag,
            'My Rentals',
            'Items you are currently renting',
                () {
              print('My Rentals Tapped');
            },
          ),

          // Account Settings
          _buildMenuTile(
            context,
            Icons.settings,
            'Account Settings',
            'Update your profile details',
                () {
              print('Settings Tapped');
            },
          ),

          const Divider(height: 32),

          // --- LOGOUT BUTTON (Red-styled, separate section) ---
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  // --- Reusable Menu Tile Helper ---
  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // --- Logout Tile Helper ---
  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: Colors.red,
      ),
      title: const Text(
        'Logout',
        style: TextStyle(fontSize: 18, color: Colors.red),
      ),
      onTap: () => _confirmLogout(context),
    );
  }
}