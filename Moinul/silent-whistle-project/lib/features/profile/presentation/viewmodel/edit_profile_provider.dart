import 'dart:io';
import 'package:dio/dio.dart'; 
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class EditShoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> editShout({
    required String id, 
    required String content,
    required String category,
    required String location,
    required String latitude,
    required String longitude,
    required bool isAnonymous,
    File? imageFiles,
    File? videoFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final url = ApiEndPoints.editshout(id);


      Map<String, dynamic> body = {
        'content': content,
        'category': category,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'is_anonymous': isAnonymous.toString(), 
      };

  
      List<MultipartFile> files = [];

      if (imageFiles != null) {
        files.add(await MultipartFile.fromFile(
          imageFiles.path,
          filename: imageFiles.path.split('/').last,
        ));
      }

      if (videoFile != null) {
        files.add(await MultipartFile.fromFile(
          videoFile.path,
          filename: videoFile.path.split('/').last,
        ));
      }

      if (files.isNotEmpty) {
        body['images'] = files.length == 1 ? files.first : files; 
     
      }

      final formData = FormData.fromMap(body);

      final response = await _apiService.patch(url, data: {
        
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = response.data['message'] ?? "Shout updated successfully";
        return true;
      } else {
        _errorMessage = response.data['message'] ?? "Failed to update shout";
        return false;
      }
    } catch (e) {
      _errorMessage = "Something went wrong: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}