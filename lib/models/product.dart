import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final String subCategory;
  final String image;
  final String description;
  final double price;
  final bool isHidden;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.image,
    required this.description,
    required this.price,
    this.isHidden = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      String rawImage = json['image'] ?? '';
      String finalImage = rawImage;
      String source = json['source'] ?? 'local';

      // Subcategory logic
      String subCat = json['type'] ?? json['sub_category'] ?? '';

      // 🚀 STEP 1: Fix the Image Port (Changed from 8001 to 8000)
      // Check if rawImage already starts with http to avoid double prefixing
      if (rawImage.startsWith('http')) {
        finalImage = rawImage;
      } else if (source == 'remote') {
        if (kIsWeb) {
          finalImage = 'http://localhost:8000/assets/images/$rawImage';
        } else {
          finalImage = 'http://10.0.2.2:8000/assets/images/$rawImage';
        }
      } else {
        // LOCAL (JSON) Fallback
        if (!rawImage.startsWith('assets/images/')) {
          finalImage = 'assets/images/$rawImage';
        }
      }

      return Product(
        id: json['id'] ?? 0,
        // 🚀 STEP 2: Robust Name Mapping (API vs Local)
        name: json['name'] ?? json['product_name'] ?? 'Unknown Product',
        category: json['category'] ?? '',
        // Map 'type' (API) or 'sub_category' (Local)
        subCategory: subCat,
        image: finalImage,
        description: json['description'] ?? '',
        // Safely parse price (String or Num)
        price: double.tryParse(json['price'].toString()) ?? 0.0,
        // Hide 'suncreen' (FaceCare) but keep 'bodysunscreen' (BodyCare)
        isHidden: subCat == 'suncreen',
      );
    } catch (e) {
      print("Error parsing product: $e");
      return Product(
        id: 0,
        name: "Offline Product",
        category: "Unknown",
        subCategory: "Unknown",
        image: "assets/images/cl1.jpeg", // Safe asset
        description: "Data unavailable",
        price: 0.0,
        isHidden: true,
      );
    }
  }
}
