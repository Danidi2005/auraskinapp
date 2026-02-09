import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class HardwareService {
  final Battery _battery = Battery();
  final ImagePicker _picker = ImagePicker();

  // 🔋 Logic for Battery Status
  Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }

  // 📍 Logic for Geolocation (GPS)
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  // 📷 Logic for Camera Sensor
  Future<String?> pickProfileImage() async {
    // This will open the camera specifically for a profile photo
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image?.path;
  }
}
