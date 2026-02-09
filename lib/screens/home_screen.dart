import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/product_card.dart';
import '../providers/app_provider.dart';
import '../services/data_service.dart';
import '../models/product.dart';
import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.black, // Sleek AuraSkin Dark Mode
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // STATUS INDICATOR IN APPBAR
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: DataService.isOnlineNotifier,
            builder: (context, isOnline, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isOnline
                                ? Colors.green.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (!isOnline) ...[
                      const SizedBox(width: 8),
                      const Text(
                        "Offline",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "AURASKIN",
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal, // Straight Text
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Radiate Your Natural Glow",
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 1.2,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. FIXED BANNER: Responsive Height & Scale
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  // We set a fixed height that looks good in Landscape vs Portrait
                  height: isPortrait ? 200 : 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/homebanner.png',
                      // BoxFit.cover prevents stretching/ugly gaps
                      fit: BoxFit.cover,
                      // This keeps the center of your banner (the face/text) visible
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Text(
                  "Best Seller",
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    color: Colors.white,
                  ),
                ),
              ),

              // 3. PRODUCT GRID SECTION
              FutureBuilder<List<Product>>(
                future: DataService().fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFAB6A2C),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Preparing your glow...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final products = snapshot.data!
                      .where((p) => !p.isHidden)
                      .take(8)
                      .toList();

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isPortrait ? 2 : 4, // Orientation Match
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // PASS UNIQUE KEY TO PREVENT FLICKER
                      return ProductCard(
                        key: ValueKey(product.id),
                        product: product,
                        isFavorite: appProvider.favoriteIds.contains(
                          product.id,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailsScreen(product: product),
                            ),
                          );
                        },
                        onFavoriteToggle: () =>
                            appProvider.toggleFavorite(product),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
