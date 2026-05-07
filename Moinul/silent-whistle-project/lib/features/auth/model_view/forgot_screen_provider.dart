import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart'
    show ApiService;
import 'package:jwells/features/auth/model/forgot_password_model.dart';

class ForgotScreenProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ForgotPasswordModel? _forgotPass;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  ForgotPasswordModel? get forgotpass => _forgotPass;

  Future<void> forgotPass({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final response = await _apiService.post(
        ApiEndPoints.forgotPw,
        data: {'email': email.trim()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage =
            response.data['message'] ?? "Reset link sent to your email!";
        _forgotPass = ForgotPasswordModel.fromJson(response.data);
        debugPrint("Success: $_successMessage");
      } else {
        _errorMessage = response.data['message'] ?? "Something went wrong";
        debugPrint("Failed: $_errorMessage");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _errorMessage = e.response?.data['message'] ?? "Server error occurred";
      } else {
        _errorMessage = "Network error. Please check your connection.";
      }
      debugPrint("Dio Error: ${e.message}");
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      debugPrint("Forgot Password Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
