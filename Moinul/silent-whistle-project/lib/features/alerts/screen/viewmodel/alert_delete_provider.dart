import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/alerts/data/model/notify_model.dart';

class AlertDeleteProvider extends ChangeNotifier{
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  String? _error;
  String? _success;


  bool get isLoading => _isLoading;

  String? get error => _error;
  String? get success => _success;
  

  Future<bool> notifyDelete({required String id}) async {
  try {
    _isLoading = true;
    _error = null; 
    notifyListeners();

    final url = ApiEndPoints.notifiDelete(id);
    final response = await _apiService.delete(url);
    final data = response.data;

    _isLoading = false; 

    if (response.statusCode == 200 || response.statusCode == 201) {
      _success = data['message'];
      notifyListeners();
      return true;
    } else {
      _error = data['message'] ?? "Something went wrong";
      notifyListeners();
      return false;
    }
  } catch (e) {
    _isLoading = false;
    _error = "Connection Error";
    notifyListeners();
    return false;
  }
}

}