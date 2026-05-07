import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';

class LoadRepliedProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<List<CommentObj>> loadReplyComment({required String id}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndPoints.loadReply(id));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic> replyList = (data is List)
            ? data
            : (data['data'] ?? data['replies'] ?? []);
        _isLoading = false;
        notifyListeners();
        return replyList.map((json) => CommentObj.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = "Something went wrong";
    }
    _isLoading = false;
    notifyListeners();
    return [];
  }
}
