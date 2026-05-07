import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/map/data/model/map_model.dart';

class MapProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService(); 
  bool _isLoading = false;
  String? _errorMessage;
  MapModel? _mapModel;
  Data? _selectedLocation;
  GoogleMapController? _mapController;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MapModel? get mapModel => _mapModel;
  Data? get selectedLocation => _selectedLocation;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void moveToSavedLocation({
    required double lat,
    required double lng,
    required String name,
    required String address,
  }) {
    _selectedLocation = Data(
      latitude: lat,
      longitude: lng,
      name: name,
      address: address,
      placeId: "saved_${DateTime.now().millisecondsSinceEpoch}", 
    );

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
      );
    }
    notifyListeners();
  }

  void selectLocation(Data location) {
    _selectedLocation = location;
    if (_mapController != null && location.latitude != null && location.longitude != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(location.latitude!, location.longitude!), 15),
      );
    }
    notifyListeners();
  }

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 2) {
      _mapModel = null;
      notifyListeners();
      return;
    }
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final String url = "${ApiEndPoints.mapSearch}?query=$query";
      final response = await _apiService.get(url);
      
      if (response != null) {
        final dynamic jsonData = (response is Map) ? response : response.data;
        if (jsonData['success'] == true) {
          _mapModel = MapModel.fromJson(jsonData);
        } else {
          _errorMessage = jsonData['message'] ?? "No result found";
        }
      }
    } on DioException catch (e) {
      _mapModel = null; 
      if (e.response?.statusCode == 403) {
        _errorMessage = "Please buy a subscription to search.";
      } else {
        _errorMessage = "No result found";
      }
    } catch (e) {
      _mapModel = null;
      _errorMessage = "No result found";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}