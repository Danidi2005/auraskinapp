import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auraapp/screens/login_screen.dart';
import 'package:auraapp/screens/register_screen.dart';
import '../main_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- STATE VARIABLES ---
  XFile? _pickedFile;
  int _batteryLevel = 100;
  String _locationName = "Set your location";
  final Battery _battery = Battery();

  // AUTH STATE
  bool _isLoggedIn = false;
  String _userName = "Guest User";
  String _userEmail = "Welcome to AuraSkin";

  @override
  void initState() {
    super.initState();
    _getBatteryStatus();
    _checkAuthStatus(); // Load User Data
  }

  // CHECK AUTH STATUS & LOAD DATA
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');

    if (token != null && token.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _userName = name ?? "User";
          _userEmail = email ?? "User Email";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userName = "Guest User";
          _userEmail = "Welcome to AuraSkin";
        });
      }
    }
  }

  // LOGOUT LOGIC
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data

    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userName = "Guest User";
        _userEmail = "Welcome to AuraSkin";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully"),
          backgroundColor: Color(0xFFAB6A2C),
        ),
      );
      // Optional: Refresh/Restart App
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
        (route) => false,
      );
    }
  }

  // 1. DEVICE CAPABILITY: BATTERY SENSOR
  void _getBatteryStatus() async {
    final level = await _battery.batteryLevel;
    if (mounted) setState(() => _batteryLevel = level);
  }

  // 2. DEVICE CAPABILITY: CAMERA SENSOR
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
    );

    if (image != null && mounted) {
      setState(() {
        _pickedFile = image;
      });
    }
  }

  // 3. GEO-LOCATION (Manual Trigger Only)
  Future<void> _determinePosition() async {
    // UI Feedback: "Locating..."
    if (mounted) setState(() => _locationName = "Locating...");

    try {
      // 1. Service Check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted)
          setState(() => _locationName = "Location: Colombo, Sri Lanka");
        return;
      }

      // 2. Permission Check (Manual Popup)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted)
            setState(() => _locationName = "Location: Colombo, Sri Lanka");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted)
          setState(() => _locationName = "Location: Colombo, Sri Lanka");
        return;
      }

      // 3. Get Position (Low Accuracy for Speed)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 4. Get Address (With Timeout & Fallback)
      try {
        // timeout 8 seconds
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 8));

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          if (mounted) {
            setState(() {
              _locationName = "${place.locality}, ${place.country}";
            });
          }
        } else {
          throw Exception("No placemarks found");
        }
      } catch (e) {
        // FALLBACK: Raw Coordinates
        if (mounted) {
          setState(() {
            _locationName =
                "Lat: ${position.latitude.toStringAsFixed(2)}, Lng: ${position.longitude.toStringAsFixed(2)}";
          });
        }
      }
    } catch (e) {
      print("Geolocation Error: $e");
      if (mounted) {
        setState(() => _locationName = "Location: Colombo, Sri Lanka");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // CENTERED HEADER
            const Center(
              child: Text(
                "PROFILE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // PROFILE PICTURE
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 75,
                backgroundColor: Colors.white10,
                backgroundImage: _pickedFile != null
                    ? (kIsWeb
                          ? NetworkImage(_pickedFile!.path)
                          : FileImage(File(_pickedFile!.path)) as ImageProvider)
                    : null,
                child: _pickedFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Add Photo",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // DYNAMIC USER INFO (Name & Email)
            Text(
              _userName, // Displays Name or "Guest User"
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'PlayfairDisplay', // Requested Font
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _userEmail, // Displays Email or "Welcome..."
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 40),

            // DEVICE STATUS SECTION
            _buildInfoTile(
              Icons.battery_charging_full,
              "Device Battery Status",
              "$_batteryLevel%",
            ),
            _buildInfoTile(
              Icons.location_on_outlined,
              "My Current Location",
              _locationName,
              onTap: _determinePosition,
            ),

            const SizedBox(height: 40),

            // AUTH BUTTON (Toggle Login/Logout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFAB6A2C,
                  ), // ALWAYS AuraSkin Brown
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isLoggedIn
                    ? _logout
                    : () => _showAuthOptions(context),
                child: Text(
                  _isLoggedIn ? "LOGOUT" : "LOGIN",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // REUSABLE TILE COMPONENT
  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFAB6A2C)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
        ),
        maxLines: 2, // UI POLISH: Overflow Protection
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }

  // AUTH OPTIONS BOTTOM SHEET
  void _showAuthOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.login, color: Colors.white),
              title: const Text(
                "Login to AuraSkin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, color: Colors.white),
              title: const Text(
                "Create an Account",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
