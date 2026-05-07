import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';
import 'package:jwells/features/auth/model/shoutModel.dart';

class CreateShoutProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  ShoutModel? _shoutmodel;
  final TokenStorage _tokenStorage = TokenStorage();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  ShoutModel? get shoutmodel => _shoutmodel;

  Future<bool> postShout({
    required String content,
    required String category,
    required String location,
    required double latitude,
    required double longitude,
    required bool isAnonymous,
    File? audioFile,
    List<File>? imageFiles,
    List<File>? videoFiles, 
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _shoutmodel = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        _errorMessage = "Authentication token not found";
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndPoints.shout),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['content'] = content;
      request.fields['category'] = category;
      request.fields['location'] = location;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['is_anonymous'] = isAnonymous ? '1': '0';

      if (audioFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('audio', audioFile.path),
        );
      }

     
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('images', file.path),
          );
        }
      }

      if (videoFiles != null && videoFiles.isNotEmpty) {
        for (var file in videoFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('images', file.path),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodeData = jsonDecode(response.body);

        if (decodeData['data'] != null) {
          _shoutmodel = ShoutModel.fromJson(decodeData['data']);
        } else {
          _shoutmodel = ShoutModel.fromJson(decodeData);
        }

        debugPrint("Shout Created Successfully");
        _successMessage="Shout creted SuccessFully";
        return true;
      } else if (response.statusCode == 401) {
        _errorMessage = "Session expired. Please login again.";
        return false;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? "Failed to upload (${response.statusCode})";
        } catch (_) {
          _errorMessage = "Failed to load data (${response.statusCode})";
        }
        return false;
      }
    } catch (e) {
      _errorMessage = "Connection Error: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}