import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/auth/model/resend_code_model.dart';

class ResendCodeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isloading = false;
  String? _errormessage;
  String? _successmessage;
  ResendCodeModel? _resendCodemodel;

  bool get isloading => _isloading;
  String? get errormessage => _errormessage;
  String? get successmessage => _successmessage;
  ResendCodeModel? get resendCodeModel => _resendCodemodel;

  Future<bool> resendcode({required String email}) async {
    _isloading = true;
    _errormessage = null;
    _successmessage = null;
    notifyListeners();

    bool isSuccess = false; 

    try {
      final response = await _apiService.post(
        ApiEndPoints.resendCode,
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successmessage = response.data['message'] ?? "Reset link sent to your email!";
        _resendCodemodel = ResendCodeModel.fromJson(response.data);
        isSuccess = true; 
      } else {
        _errormessage = response.data['message'] ?? "Something went wrong";
        debugPrint("Failed: $_errormessage");
        isSuccess = false;
      }
    } on DioException catch (e) {
      isSuccess = false;
      if (e.response != null) {
   
        _errormessage = e.response?.data['message'] ?? "Server error occurred";
      } else {
  
        _errormessage = "Network error. Please check your connection.";
      }
      debugPrint("Dio Error: ${e.message}");
    } catch (e) {
      isSuccess = false;
      _errormessage = "An unexpected error occurred.";
      debugPrint("Forgot Password Error: $e");
    } finally {
  
      _isloading = false;
      notifyListeners();
    }

    return isSuccess; 
  }
}