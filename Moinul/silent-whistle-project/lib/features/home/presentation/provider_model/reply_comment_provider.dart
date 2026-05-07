import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart'; 

class ReplyCommentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<CommentObj?> replyComment({
    required String shoutId,   
    required String content,
    required String parentId,  
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndPoints.comment(shoutId), 
        data: {
          "content": content,
          "parent_id": parentId, 
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommentObj.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Reply Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}