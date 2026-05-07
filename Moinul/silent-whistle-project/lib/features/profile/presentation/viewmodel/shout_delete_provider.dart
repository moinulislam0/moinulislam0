import 'package:flutter/material.dart';
import '../../../../core/constant/api_endpoints.dart';
import '../../../../core/services/api_services/api_services.dart';
import '../../data/model/shout_post_delete_response_model.dart';

class ShoutPostDeleteProvider with ChangeNotifier {
  final ApiService _apiService;

  ShoutPostDeleteProvider( ApiService apiService) : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;
  ShoutPostDeleteResponseModel? _deleteAccountResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ShoutPostDeleteResponseModel? get deleteAccountModel =>
      _deleteAccountResponse;

  Future<bool> deletePost(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        ApiEndPoints.postDelete(id),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _deleteAccountResponse =
            ShoutPostDeleteResponseModel.fromJson(response.data);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Failed to delete account';
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _deleteAccountResponse = null;
    notifyListeners();
  }
}
