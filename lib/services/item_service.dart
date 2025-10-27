// lib/services/item_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import 'auth_service.dart';

class ItemService {
  // !! Make sure this is your Wi-Fi IP Address !!
  final String _baseUrl = "http://192.168.76.14:5000"; // <-- UPDATE THIS

  final AuthService _authService = AuthService();

  // --- Get Items Nearby Method (Unchanged) ---
  Future<List<Item>> getItemsNearby(double latitude, double longitude) async {
    // ... (This function is unchanged)
    final String? token = await _authService.getToken();
    if (token == null) { return []; }

    final String url = "$_baseUrl/api/items/nearby?lat=$latitude&lng=$longitude";
    print('Fetching items from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> jsonList = responseData['data'];
        List<Item> items =
        jsonList.map((json) => Item.fromJson(json)).toList();
        return items;
      } else {
        print('Failed to load items: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }




  // --- Add New Item Method (Unchanged) ---
  Future<bool> addItem({
    required String title,
    required String description,
    required double pricePerDay,
    required String category,
    required File image,
    required double latitude,
    required double longitude,
  }) async {
    // ... (This function is unchanged)
    final String? token = await _authService.getToken();
    if (token == null) { return false; }

    final String url = "$_baseUrl/api/items";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      // Add Text Fields
      request.fields['name'] = title;
      request.fields['description'] = description;
      request.fields['rentalPrice'] = pricePerDay.toString();
      request.fields['category'] = category;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      // Add the Image File
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Item uploaded successfully!');
        return true;
      } else {
        print('Failed to upload item: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error uploading item: $e');
      return false;
    }
  }

  Future<bool> rentItem(String itemId, String startDate, String endDate) async {
    final String? token = await _authService.getToken();
    if (token == null) return false;

    final String url = "$_baseUrl/api/items/$itemId/rent";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 201) {
        print('Rental successful!');
        return true;
      } else {
        print('Rental failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during rental: $e');
      return false;
    }
  }

  // lib/services/item_service.dart

  Future<bool> toggleItemStatus(String itemId, bool newStatus) async { // Renamed param for clarity
    final String? token = await _authService.getToken();
    if (token == null) return false;

    final String url = "$_baseUrl/api/items/$itemId/status";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        // --- FIX: Send the simple, untoggled 'newStatus' value ---
        body: jsonEncode({'isAvailable': newStatus}),
      );

      // Check for success status code
      return response.statusCode == 200;

    } catch (e) {
      print('Error during status toggle request: $e'); // Add log for diagnosis
      return false;
    }
  }

  // --- NEW: Get User's Own Items ---
  Future<List<Item>> getMyItems() async {
    final String? token = await _authService.getToken();
    if (token == null) {
      print('No token found. User is not logged in.');
      return []; // Not authorized
    }

    final String url = "$_baseUrl/api/items/my"; // Your backend route
    print('Fetching user\'s items from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Success!
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> jsonList = responseData['data']; // Get the 'data' array

        List<Item> items =
        jsonList.map((json) => Item.fromJson(json)).toList();

        return items;
      } else {
        // Handle server error
        print('Failed to load my items: ${response.body}');
        return []; // Return an empty list
      }
    } catch (e) {
      // Handle exception
      print('Error fetching my items: $e');
      return []; // Return an empty list
    }
  }
}