import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/features/auth/model/forgot_verify_model.dart';

class FotgetVerifyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> forgotverify({
    required String email,
    required String otp,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _safeNotifyListeners();

      ForgotVerifyModel forgotVerifyModel = ForgotVerifyModel(
        email: email,
        otp: otp,
      );

      final url = Uri.parse(ApiEndPoints.forgotVerify);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(forgotVerifyModel.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
          "Response Body: ${response.body}",
        );
        debugPrint(
          "Status Code: ${response.statusCode}",
        );
        _successMessage = data['message'] ?? "Email verified successfully";
        debugPrint("Success: $_successMessage");
        return true;
      } else {
        _errorMessage =
            data['message'] ??
                "Something went wrong (Code: ${response.statusCode})";
        debugPrint("Failed: $_errorMessage");
        return false;
      }
    } catch (e) {
      _errorMessage = "Network error. Please check your connection.";
      debugPrint("Forgot Verify Error: $e");
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}