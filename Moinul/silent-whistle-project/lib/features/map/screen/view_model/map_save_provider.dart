import 'package:flutter/foundation.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class MapSaveProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  ApiService get appiservice => _apiService;
  bool get isloading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> saveMapLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String placeId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners(); 

      final url = ApiEndPoints.mapSave;
      final response = await _apiService.post(url, data: {
        "name": name,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "place_id": placeId
      });

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = data["message"] ?? "Location saved successfully!";
        return true;
      } else {
        _errorMessage = data['message'] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      _errorMessage = "Connection error: ${e.toString()}";
      return false;
    } finally {
     
      _isLoading = false;
      notifyListeners(); 
    }
  }
}