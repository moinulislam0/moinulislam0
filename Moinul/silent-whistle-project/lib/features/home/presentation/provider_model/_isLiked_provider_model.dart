import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class isLikedProvider extends ChangeNotifier {
  ApiService _apiService = ApiService();
  bool _isloading = false;
  String? _isSuccess;
  String? _isError;

  bool get isloading => _isloading;
  String? get isSuccess => _isSuccess;
  String? get isError => _isError;

  Future<bool> isliked({required String id}) async {
    _isloading = true;
    _isError = null;
    _isSuccess = null;
    notifyListeners();

    try {
      // API Call
      final response = await _apiService.post(ApiEndPoints.like(id));
      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSuccess = data['message'] ?? "success liked";
        debugPrint("Success Like API: $_isSuccess");

        _isloading = false;
        notifyListeners();
        return true;
      } else {
        _isError = response.data['message'] ?? "Something went wrong";
        debugPrint("Failed Like API: $_isError");

        _isloading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _isError = e.response?.data['message'] ?? "Server error occurred";
        debugPrint("Dio Error Response: ${e.response?.data}");
      } else {
        _isError = "Network error. Please check your connection.";
      }
      debugPrint("Dio Error: ${e.message}");

      _isloading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isError = "An unexpected error occurred.";
      debugPrint("Generic Error: $e");

      _isloading = false;
      notifyListeners();
      return false;
    }
  }
}
