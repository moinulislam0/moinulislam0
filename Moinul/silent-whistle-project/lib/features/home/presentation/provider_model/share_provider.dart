import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class ShareProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> share({
    required String id,
    required String content,
    required bool isAnonymous,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final url = ApiEndPoints.share(id);
      final response = await _apiService.post(
        url,
        data: {
          "content": content,
          "is_anonymous": isAnonymous,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = data["message"];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data["message"];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
