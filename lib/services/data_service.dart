import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';

class DataService {
  // 📡 Step 1: Universal URL Logic (Port 8000 to match your active terminal)
  static ValueNotifier<bool> isOnlineNotifier = ValueNotifier(true);

  String get apiURL {
    if (kIsWeb) {
      return "http://localhost:8000/api/products"; // Chrome
    } else {
      return "http://10.0.2.2:8000/api/products"; // Android Emulator
    }
  }

  Future<List<Product>> fetchProducts() async {
    // 📡 Step 2: Check Connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      print('Connecting to API: $apiURL'); // Requirement: Traffic Log

      // Retry mechanism: Attempt 3 times
      for (int i = 0; i < 3; i++) {
        try {
          print('Attempt ${i + 1} of 3...');
          final response = await http
              .get(
                Uri.parse(apiURL),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'Connection': 'keep-alive', // FIX: Keep connection open
                },
              )
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            print("API Success: Data received from Laravel");
            isOnlineNotifier.value = true; // STATUS: ONLINE

            try {
              // FIX: Handle "Unexpected end of input"
              List<dynamic> data = json.decode(response.body);

              for (var item in data) {
                item['source'] = 'remote';
              }
              return data.map((item) => Product.fromJson(item)).toList();
            } catch (jsonError) {
              print("JSON Error: $jsonError. Falling back to local data.");
              // Fallback logic handled by outer catch or explicit return here?
              // User said: "immediately returns the assets/data/products.json fallback"
              throw Exception(
                "JSON Malformed",
              ); // Trigger catch block -> fallback
            }
          } else {
            print("API Error: Status ${response.statusCode}");
          }
        } catch (e) {
          print("API Error (Attempt ${i + 1}): $e");
          if (i == 2) {
            // On final failure, load local JSON
            print("Switching to LOCAL JSON Fallback...");
            final String localData = await rootBundle.loadString(
              'assets/data/products.json',
            );
            List<dynamic> data = json.decode(localData);
            isOnlineNotifier.value = false;
            return data.map((item) => Product.fromJson(item)).toList();
          }
        }
      }
      print("All 3 attempts failed. Switching to Offline Fallback...");
      isOnlineNotifier.value = false; // STATUS: OFFLINE (Fallback)
    } else {
      print("Device is Offline. Using local JSON data.");
      isOnlineNotifier.value = false; // STATUS: OFFLINE
    }

    // 📡 Step 4: Offline Fallback (Local JSON)
    try {
      final String localData = await rootBundle.loadString(
        'assets/data/products.json',
      );
      List<dynamic> data = json.decode(localData);

      // Inject 'local' source context for your report
      for (var item in data) {
        item['source'] = 'local';
      }
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      print("Local JSON Critical Error: $e");
      return [];
    }
  }
}
