import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class DisableAccountProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isloading = false;
  String? _successmessage;
  String? _errorMessage;

  bool get isloading => _isloading;
  String? get successMessage => _successmessage;
  String? get errorMessage => _errorMessage;


  Future<bool> toggleAccountStatus() async {
    try {
      _isloading = true;
      _errorMessage = null;
      _successmessage = null;
      notifyListeners();

      
      final response = await _apiService.post(ApiEndPoints.disableAccount);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successmessage = response.data['message'] ?? "Status Updated Successfully";
        return true;
      } else {
        _errorMessage = response.data['message'] ?? "Operation Failed";
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? "Server Error";
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred";
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}