import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class EditProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isloading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isloading => _isloading;
  String? get errormessage => _errorMessage;
  String? get successMessage => _successMessage; 

  Future<bool> editProfile({
    required String name,
    required String about,
    required String address,
    required String phone_number,
    required String gender,
    required String date_of_birth,
  }) async {
    _isloading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final url = ApiEndPoints.editProfile;

      final response = await _apiService.patch(url, data: {
        'name': name,
        "about": about,
        'address': address,
        'phone_number': phone_number,
        'gender': gender,
        'date_of_birth': date_of_birth,
        'city': '', 
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = response.data['message'] ?? "Profile updated successfully";
        return true;
      } else {
        _errorMessage = response.data['message'] ?? "Failed to update profile";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}