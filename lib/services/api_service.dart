import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ApiService {
  // The 'Anti-Gravity' URL Switch
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8000/api"; // For Web
    return "http://10.0.2.2:8000/api"; // For Android Emulator
  }

  // 1. DATA FETCH: Products (Requirement: External API)
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/products"))
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return []; // Triggers your local JSON fallback
    }
  }

  // 2. AUTH: Login (Requirement: SSP Jetstream API)
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {'email': email, 'password': password},
    );
    return response.statusCode == 200;
  }

  // 3. SENSOR: Fast Geolocation (Requirement: Sensors)
  static Future<String> getQuickLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // 'Low' is fast/anti-freeze
        timeLimit: const Duration(seconds: 5),
      );
      List<Placemark> marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      return marks.isNotEmpty
          ? "${marks.first.locality}, ${marks.first.country}"
          : "Unknown";
    } catch (e) {
      return "Location Fallback (Colombo)";
    }
  }
}
