import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';

class DeleteAccountProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  bool _isloading = false;
  String? _successmessage;
  String? _errorMessage;

  bool get isloading => _isloading;
  String? get successMessage => _successmessage;
  String? get errorMessage => _errorMessage;

  Future<bool> deleteAccount() async {
    try {
      _isloading = true;
      _errorMessage = null;
      _successmessage = null;
      notifyListeners();

      final response = await _apiService.post(ApiEndPoints.deleteAccount);

      if (response.statusCode == 200 || response.statusCode == 201) {
   
        await _tokenStorage.clearToken();
        _successmessage = "Delete Successfully";
        return true;
      } else {
        _errorMessage = response.data['message'] ?? "Delete Failed";
        return false;
      }
    } on DioException catch (e) {
   
      _errorMessage = e.response?.data['message'] ?? "Server Error (404): Route not found";
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