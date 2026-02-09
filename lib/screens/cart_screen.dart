import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<AppProvider>(context);
    final items = cartProvider.cartItems;

    return Scaffold(
      backgroundColor: Colors.black, // 3. AuraSkin Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "MY SHOPPING BAG",
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        // Optional: Add Clear Cart button if provider supports it
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // 1. RELIABLE LIST VIEW (Wrapped in Expanded)
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      final qty = cartProvider.cartQuantities[product.id] ?? 1;
                      final itemTotal = product.price * qty;

                      return _buildCartItem(
                        context,
                        product,
                        qty,
                        itemTotal,
                        cartProvider,
                      );
                    },
                  ),
                ),

                // 2. SUMMARY SECTION (Grand Total)
                _buildSummarySection(cartProvider),
              ],
            ),
    );
  }

  // --- CART ITEM WIDGET ---
  Widget _buildCartItem(
    BuildContext context,
    Product product,
    int qty,
    double itemTotal,
    AppProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark Card Background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // IMAGE with Rounded Corners
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.image.startsWith('http')
                ? Image.network(
                    product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.asset(
                      'assets/images/cl1.jpeg',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 15),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  product.subCategory,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  "LKR ${product.price.toStringAsFixed(2)}", // Unit Price
                  style: const TextStyle(
                    color: Color(0xFFAB6A2C), // AuraSkin Brown
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // QUANTITY CONTROLS & TOTAL
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _buildQtyBtn(
                    Icons.remove,
                    () => provider.decreaseQuantity(product),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "$qty",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildQtyBtn(Icons.add, () => provider.addToCart(product, 1)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "LKR ${itemTotal.toStringAsFixed(2)}", // Item Total
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  // --- SUMMARY SECTION ---
  Widget _buildSummarySection(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grand Total",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "LKR ${provider.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFFAB6A2C), // AuraSkin Gold/Brown
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAB6A2C),
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                // Implement Checkout logic here
              },
              child: const Text(
                "PROCEED TO CHECKOUT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white24),
          SizedBox(height: 20),
          Text(
            "Your bag is empty",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
