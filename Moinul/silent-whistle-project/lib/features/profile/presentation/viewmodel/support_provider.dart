import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class SupportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isloading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isloading => _isloading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> support({required String subject, required String message}) async {
    _isloading = true; 
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final url = ApiEndPoints.support;
      final response = await _apiService.post(url, data: {
        "subject": subject,
        "message": message,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _successMessage = response.data['message'] ?? "Message sent successfully!";
        return true;
      } else {
        _errorMessage = response.data['message'] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      _errorMessage = "Connection error. Please try again.";
      return false;
    } finally {
      _isloading = false; 
      notifyListeners();
    }
  }
}