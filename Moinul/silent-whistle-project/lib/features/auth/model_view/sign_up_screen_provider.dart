import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/features/auth/model/sing_up_model.dart';

class SignUpScreenProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
      notifyListeners();

      SingUpModel signUpData = SingUpModel(
        email: email,
        name: name,
        password: password,
        username: username,
        latitude: 23.8103,
        longitude: 90.4125,
      );

      final url = Uri.parse(ApiEndPoints.signUp);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(signUpData.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = "Registration Successful!";
        print(response.body);
        return true;
          
      
      } else if (response.statusCode >= 500) {
     
        _errorMessage = "Server error. Please try again later.";
        return false;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
   
        String apiMsg = data['message']?.toString().toLowerCase() ?? "";
        if (apiMsg.contains("already") || apiMsg.contains("exists")) {
          _errorMessage = "This email or username is already registered.";
        } else {
          _errorMessage = data['message']?.toString() ?? "Invalid details provided.";
        }
        return false;
      } else {
        _errorMessage = "Something went wrong. Please try again.";
        return false;
      }
    } on SocketException {
  
      _errorMessage = "Network issue. Please check your internet connection.";
      return false;
    } catch (e) {
     
      _errorMessage = "An unexpected error occurred.";
      debugPrint("SignUp Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}