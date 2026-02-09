import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../services/data_service.dart';
import '../components/product_card.dart';

class DetailsScreen extends StatefulWidget {
  final Product product;
  const DetailsScreen({super.key, required this.product});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sleek AuraSkin Dark Theme
      // Allows the image to go behind the transparent app bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // BACK BUTTON: Top Left as requested
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isPortrait = orientation == Orientation.portrait;
          return isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout();
        },
      ),
    );
  }

  // --- PORTRAIT LAYOUT ---
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Image Display
          widget.product.image.startsWith('http')
              ? Image.network(
                  widget.product.image,
                  width: double.infinity,
                  height: 450,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/cl1.jpeg',
                    width: double.infinity,
                    height: 450,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  widget.product.image,
                  width: double.infinity,
                  height: 450,
                  fit: BoxFit.cover, // Ensuring full display suitable way
                ),
          _buildMainContent(),
        ],
      ),
    );
  }

  // --- LANDSCAPE LAYOUT: SIDE-BY-SIDE ---
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: widget.product.image.startsWith('http')
              ? Image.network(
                  widget.product.image,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/cl1.jpeg',
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  widget.product.image,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(child: _buildMainContent()),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.product.subCategory.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFAB6A2C),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          // PRICE IN WHITE
          Text(
            "LKR ${widget.product.price.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // QUANTITY SELECTOR: Now Under Price as requested
          _buildQtySelector(),
          const SizedBox(height: 25),
          // DESCRIPTION: Bold and Big, Topic "Product Description" Removed
          Text(
            widget.product.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.5,
              fontStyle: FontStyle.normal, // Straight Text
            ),
          ),
          const SizedBox(height: 25),
          // ADD TO CART BUTTON: Under the Description
          _buildAddToCartButton(),
          const SizedBox(height: 40),
          // YOU MAY ALSO LIKE: Scrollable List
          _buildRelatedProductsSection(),
        ],
      ),
    );
  }

  Widget _buildQtySelector() {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() {
            if (quantity > 1) quantity--;
          }),
          icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
        ),
        Text(
          "$quantity",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            quantity++;
          }),
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAB6A2C),
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Provider.of<AppProvider>(
            context,
            listen: false,
          ).addToCart(widget.product, quantity);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Added to bag"),
              backgroundColor: Color(0xFFAB6A2C),
            ),
          );
        },
        child: const Text(
          "ADD TO CART",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRelatedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "You may also like",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 260,
          child: FutureBuilder<List<Product>>(
            future: DataService().fetchProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final related = snapshot.data!
                  .where(
                    (p) =>
                        p.category == widget.product.category &&
                        p.id != widget.product.id,
                  )
                  .take(4)
                  .toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 15),
                    child: ProductCard(
                      product: related[index],
                      isFavorite: false,
                      onFavoriteToggle: () {},
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailsScreen(product: related[index]),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
