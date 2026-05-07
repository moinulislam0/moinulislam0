import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/map/data/model/map_details_model.dart';

class MapGetProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  MapDetails _mapDetails = MapDetails();
  bool _isloading = false;
  String? _successMessage;
  String? _errorMessage;

  bool get isloading => _isloading;
  MapDetails get mapDetails => _mapDetails;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> showDetails() async {
    try {
      _isloading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final url = ApiEndPoints.mapDetails;
      final response = await _apiService.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mapDetails = MapDetails.fromJson(response.data);
        _successMessage = response.data['message'] ?? "Data loaded successfully";
        return true; 
      } else {
        _errorMessage = response.data['message'] ?? "Something went wrong";
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
      _errorMessage = "Please buy a subscription to search."; 
    } else {
      _errorMessage = "Something went wrong. Please try again.";
    }
    return false;
    } catch (e) {
      _errorMessage = "Something went wrong. Please try again.";
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}