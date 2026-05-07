import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/features/auth/model/new_password_model.dart';

class NewPasswordVerify extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Future<bool> newPassVerify({
    required String email,
    required String otp,
    required String newPass,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
      NewPasswordModel newPasswordModel = NewPasswordModel(
        email: email,
        otp: otp,
        newPassword: newPass,
      );
      final url = Uri.parse(ApiEndPoints.newPassword);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newPasswordModel.toJson()),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode ==200 || response.statusCode ==201) {
        _successMessage = data['message'] ?? "Reset link sent to your email!";
        debugPrint("Success: $_successMessage");
        return true;
      } else {
        _errorMessage =
            data['message'] ?? "error message ${response.statusCode}";
        debugPrint("Success: $_errorMessage");
        return false;
      }
    } catch (e) {
      _errorMessage = "Network error. Please check your connection.";
      debugPrint("Forgot Password Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
