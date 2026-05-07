import 'package:shared_preferences/shared_preferences.dart';

class LocationStorage {
  static const _latitudeKey = 'saved_latitude';
  static const _longitudeKey = 'saved_longitude';
  static const _locationTextKey = 'saved_location_text';

  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    String? locationText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latitudeKey, latitude);
    await prefs.setDouble(_longitudeKey, longitude);
    if (locationText != null && locationText.trim().isNotEmpty) {
      await prefs.setString(_locationTextKey, locationText.trim());
    }
  }

  Future<double?> getLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_latitudeKey);
  }

  Future<double?> getLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_longitudeKey);
  }

  Future<void> saveLocationText(String locationText) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationTextKey, locationText.trim());
  }

  Future<String?> getLocationText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_locationTextKey);
  }
}
