import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwells/features/profile/data/model/update_profile_picture_response_model.dart';

import '../../../../core/constant/api_endpoints.dart';
import '../../../../core/services/api_services/api_services.dart';


class UpdateUserProvider with ChangeNotifier {
  final ApiService _apiService;

  UpdateUserProvider(ApiService apiService) : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;
  UpdateProfilePictureResponseModer? _updateProfilePictureResponseModer;
  bool _isProcessing = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UpdateProfilePictureResponseModer? get updateProfilePictureResponseModer => _updateProfilePictureResponseModer;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  Future<bool> updateImage(XFile? imageFile) async {
    if (_isProcessing) {
      debugPrint('⚠️ Update already in progress, ignoring duplicate call');
      return false;
    }



    _isProcessing = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔵 Sending update user request');

      // Create FormData
      Map<String, dynamic> formDataMap = {};


      // Add image file if provided
      if (imageFile != null) {
        formDataMap['avatar'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      debugPrint('📤 FormData: ${formDataMap.keys.toList()}');

      final response = await _apiService.patchMultipart(
        ApiEndPoints.profilePictureUpdate,
        formData: formData,
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map) {
          if (responseData.containsKey('success')) {
            if (responseData['success'] == false) {
              final message = responseData['message'];
              if (message is String) {
                _errorMessage = message;
              } else if (message is Map && message.containsKey('message')) {
                _errorMessage = message['message'];
              } else {
                _errorMessage = 'Failed to update profile';
              }
              return false;
            }
          }

          if (responseData.containsKey('statusCode')) {
            final bodyStatusCode = responseData['statusCode'];
            if (bodyStatusCode != 200 && bodyStatusCode != 201) {
              final message = responseData['message'];
              if (message is String) {
                _errorMessage = message;
              } else if (message is Map && message.containsKey('message')) {
                _errorMessage = message['message'];
              } else {
                _errorMessage = 'Failed to update profile';
              }
              return false;
            }
          }
        }

        _updateProfilePictureResponseModer = UpdateProfilePictureResponseModer.fromJson(response.data);
        _errorMessage = null;
        debugPrint('✅ Profile updated successfully');
        return true;
      } else {
        final message = response.data?['message'];
        _errorMessage = message is String
            ? message
            : 'Failed to update profile';
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}');
      debugPrint('❌ Response: ${e.response?.data}');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          final message = responseData['message'];
          if (message is String) {
            _errorMessage = message;
          } else if (message is Map && message.containsKey('message')) {
            _errorMessage = message['message'];
          } else {
            _errorMessage = 'Failed to update profile';
          }
        } else {
          _errorMessage = 'Failed to update profile';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        _errorMessage = 'Connection timeout. Please try again';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        _errorMessage = 'Server is not responding. Please try again';
      } else if (e.type == DioExceptionType.connectionError) {
        _errorMessage = 'Network error. Please check your connection';
      } else {
        _errorMessage = 'Network error. Please check your connection';
      }
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      _isProcessing = false;
      notifyListeners();
      debugPrint('🔵 Request completed, flags reset');
    }
  }

  // Set error manually
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _isLoading = false;
    _isProcessing = false;
    _errorMessage = null;
    _updateProfilePictureResponseModer = null;
    notifyListeners();
  }
}
