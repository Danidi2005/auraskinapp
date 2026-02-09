import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Accessing the provider to get the current cart count
    final int cartCount = context.watch<AppProvider>().cartItems.length;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFFAB6A2C), // AuraSkin Brown/Gold
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black, // Dark Theme
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal, // Straight text
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
      ),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: "Category",
        ),
        // --- UPDATED CART ITEM WITH CLEAR BOLD BADGE ---
        BottomNavigationBarItem(
          icon: Badge(
            // --- STYLING THE BADGE BACKGROUND ---
            backgroundColor: Colors.red, // Solid Red for visibility
            padding: const EdgeInsets.symmetric(horizontal: 4),
            label: Text(
              cartCount.toString(),
              style: const TextStyle(
                color: Colors.white, // White text on Red background
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            isLabelVisible: cartCount > 0, // Only visible if cart is not empty
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          activeIcon: Badge(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            label: Text(
              cartCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            isLabelVisible: cartCount > 0,
            child: const Icon(Icons.shopping_bag),
          ),
          label: "Cart",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
