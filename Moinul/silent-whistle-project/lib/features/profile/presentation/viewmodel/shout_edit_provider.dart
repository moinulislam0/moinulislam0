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
    List<File>? imageFiles,
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

      final formData = FormData.fromMap(body);


      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          formData.files.add(MapEntry(
            'images', 
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ));
        }
      }

   
      if (videoFile != null) {
        formData.files.add(MapEntry(
          'video', 
          await MultipartFile.fromFile(
            videoFile.path,
            filename: videoFile.path.split('/').last,
          ),
        ));
      }

      final response = await _apiService.patch(
        url, 
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = response.data['message'] ?? "Shout updated successfully";
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? "Failed to update shout";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}