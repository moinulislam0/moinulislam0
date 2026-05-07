import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class ReportPostProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> reportPost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiEndPoints.reportShout(postId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = response.data['message'] ?? 'Post reported successfully.';
        return true;
      }

      _errorMessage = response.data['message'] ?? 'Failed to report post.';
      return false;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message']?.toString() ??
          'Failed to report post.';
      return false;
    } catch (_) {
      _errorMessage = 'Failed to report post.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
