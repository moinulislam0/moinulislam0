import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class ReportUserProvider extends ChangeNotifier {
  final ApiService _apiService;

  ReportUserProvider(this._apiService);

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> reportUser(String userId, {String reason = 'Spam user'}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndPoints.reportUser,
        data: {
          'reported_user_id': userId,
          'reason': reason,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage =
            response.data['message']?.toString() ?? 'User reported successfully.';
        return true;
      }

      _errorMessage =
          response.data['message']?.toString() ?? 'Failed to report user.';
      return false;
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data['message']?.toString() ?? 'Failed to report user.';
      return false;
    } catch (_) {
      _errorMessage = 'Failed to report user.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
