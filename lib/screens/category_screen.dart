import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/product.dart';
import '../components/product_card.dart';
import '../providers/app_provider.dart';
import 'details_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String selectedMain = "FaceCare";
  String selectedSub = "All";

  // Spelling matches your JSON exactly
  final List<String> faceSubs = [
    "All",
    "cleanser",
    "facewash",
    "Moisturizer",
    "serum",
    // "suncreen" REMOVED as requested
  ];
  final List<String> bodySubs = [
    "All",
    "bodylotion",
    "showergel",
    "bodyscrub",
    "bodysunscreen", // KEPTS as requested
    "deodorant",
  ];

  @override
  Widget build(BuildContext context) {
    List<String> activeSubs = selectedMain == "FaceCare" ? faceSubs : bodySubs;
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "AURASKIN SHOP",
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              // Main Category Toggle (Face/Body)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["FaceCare", "BodyCare"].map((cat) {
                    bool isSel = selectedMain == cat;
                    return GestureDetector(
                      onTap: () => setState(() {
                        selectedMain = cat;
                        selectedSub = "All";
                      }),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSel ? const Color(0xFFAB6A2C) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Sub-category ChoiceChips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: activeSubs.length,
                  itemBuilder: (context, index) {
                    final sub = activeSubs[index];
                    bool isSelected = selectedSub == sub;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(
                          sub,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) => setState(() => selectedSub = sub),
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFAB6A2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFAB6A2C)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: FutureBuilder<List<Product>>(
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
                          "No products available",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    // --- LOOSE MATCHING FILTER ---
                    final filtered = snapshot.data!.where((p) {
                      // Filter out hidden products (like 'suncreen')
                      if (p.isHidden) return false;

                      final matchesMain =
                          p.category.trim().toLowerCase() ==
                          selectedMain.toLowerCase().trim();
                      final matchesSub =
                          selectedSub == "All" ||
                          p.subCategory.trim().toLowerCase() ==
                              selectedSub.toLowerCase().trim();
                      return matchesMain && matchesSub;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          "No items match this category",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(15),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: orientation == Orientation.portrait
                            ? 2
                            : 4,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => ProductCard(
                        key: ValueKey(filtered[index].id),
                        product: filtered[index],
                        isFavorite: provider.favoriteIds.contains(
                          filtered[index].id,
                        ),
                        onFavoriteToggle: () =>
                            provider.toggleFavorite(filtered[index]),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailsScreen(product: filtered[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
