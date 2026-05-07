import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';

class SignScreenProvider extends ChangeNotifier {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<void> userCreate({
    required String name,
    required String email,
    required String username,
    required String password,
    required String type,
  }) async {
    try {
      final url = Uri.parse(ApiEndPoints.register);

      final token = await _tokenStorage.getToken();

      final response = await http.post(
        url,
        headers: {
          "Authorization": token != null ? "Bearer $token" : "",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "username": username,
          "password": password,
          "type": type,
          "latitude": 23.8103,
          "longitude": 90.4125,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("User created successfully: ${response.body}");
      } else {
        debugPrint(
          "Failed to create user (${response.statusCode}): ${response.body}",
        );
      }
    } catch (error) {
      debugPrint("Error creating user: $error");
    }
  }

  Future<void> verifyOtp() async {
    try {
      final token = _tokenStorage.getToken();
      final url = Uri.parse(ApiEndPoints.verifyOtp);
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          {"email": "sazedulislam9126@gmail.com", "otp": "214932"},
        }),
      );
    } catch (error) {
      debugPrint("The error message $error");
    }
  }
}



