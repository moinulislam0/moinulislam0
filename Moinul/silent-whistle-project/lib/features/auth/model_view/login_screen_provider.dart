import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/local_storage_service/location_storage.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';

import '../model/check_me_model.dart';

class LoginScreenProvider extends ChangeNotifier {
  final TokenStorage _tokenStorage = TokenStorage();
  final LocationStorage _locationStorage = LocationStorage();

  bool isLoading = false;
  String? errorMessage;
  late final CustomAppBarProvider _userProvider;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  String _buildLoginErrorMessage({
    required int statusCode,
    String? serverMessage,
  }) {
    final message = serverMessage?.toLowerCase().trim() ?? '';

    if (message.contains('password')) {
      return 'Incorrect password.';
    }

    if (message.contains('email') ||
        message.contains('user not found') ||
        message.contains('account not found') ||
        message.contains('no user')) {
      return 'Incorrect email.';
    }

    if (statusCode == 401 ||
        message.contains('invalid credentials') ||
        message.contains('unauthorized') ||
        message.contains('invalid login')) {
      return 'Incorrect email or password.';
    }

    return 'Unable to log in right now. Please try again.';
  }

  Future<void> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final latitude = await _locationStorage.getLatitude() ?? 0;
      final longitude = await _locationStorage.getLongitude() ?? 0;
      debugPrint('User login latitude from local: $latitude');
      debugPrint('User login longitude from local: $longitude');

      final url = Uri.parse(ApiEndPoints.login);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final token = data['authorization']['access_token'];
        debugPrint("THe success message ${data['message']} $token");
        if (token != null) {
          await _tokenStorage.saveToken(token);
          await aboutUser();
        }
      } else {
        final data = jsonDecode(response.body);
        final serverMessage = data['message']?.toString();

        errorMessage = _buildLoginErrorMessage(
          statusCode: response.statusCode,
          serverMessage: serverMessage,
        );
        debugPrint("THe failed message $serverMessage");
      }
    } catch (error) {
      errorMessage = "Something went wrong";
      debugPrint("Login error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> socialLogin({
    required String type,
    Map<String, dynamic>? data,
  }) async {
    _setLoading(true);
    errorMessage = null;
    debugPrint('Social login start. type: $type, data: $data');
    debugPrint('Social login payload keys: ${data?.keys.toList() ?? []}');
    debugPrint(
      'Social login idToken present: ${data?['idToken'] != null && data?['idToken'].toString().isNotEmpty == true}',
    );
    debugPrint(
      'Social login accessToken present: ${data?['accessToken'] != null && data?['accessToken'].toString().isNotEmpty == true}',
    );

    try {
      final url = Uri.parse('${ApiEndPoints.baseUrl}/api/auth/$type/mobile');
      debugPrint('Social login url: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data ?? {}),
      );

      debugPrint('Social login statusCode: ${response.statusCode}');
      debugPrint('Social login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final token = responseData['authorization']?['access_token'];
        debugPrint('Social login success message: ${responseData['message']}');
        debugPrint('Social login token: $token');

        if (token != null) {
          await _tokenStorage.saveToken(token);
          debugPrint('Social login token saved successfully');
          await aboutUser();
        } else {
          debugPrint('Social login succeeded but token was null');
        }
      } else {
        final responseData = jsonDecode(response.body);
        errorMessage = responseData['message']?.toString() ??
            'Social login failed (${response.statusCode})';
        debugPrint('Social login failed message: $errorMessage');
        debugPrint('Social login failed full response: $responseData');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Social login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  CheckMeModel? _checkMeModel;
  CheckMeModel? get checkMeModel => _checkMeModel;

  Future<void> aboutUser() async {
    try {
      // Await the token properly
      final token = await _tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        debugPrint("No token found, user might not be logged in.");
        return;
      }

      final url = Uri.parse(ApiEndPoints.getUsers);

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      // Check status code first
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodeData = jsonDecode(response.body);
        _checkMeModel = CheckMeModel.fromJson(decodeData);

        debugPrint("User data fetched successfully: $_checkMeModel");
        notifyListeners();
      } else {
        String message = '';
        try {
          final decodeData = jsonDecode(response.body);
          message = decodeData['message'] ?? 'Unknown error';
        } catch (_) {
          message = 'Failed to parse error message';
        }

        debugPrint("Failed to fetch user data: $message");
      }
    } catch (error) {
      debugPrint('Error fetching user data: $error');
    }
  }

}
