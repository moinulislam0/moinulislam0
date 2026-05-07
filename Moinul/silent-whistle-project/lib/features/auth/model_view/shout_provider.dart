import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';
import 'package:jwells/features/auth/model/shoutModel.dart'; 
import 'package:jwells/features/home/data/model/allShoutModel.dart';

class ShoutProvider extends ChangeNotifier {
  ShoutProvider() {
    fetchAllShouts();
  }

  AllShoutModel? _shouts;
  final List<ShoutModel> _allShoutsList = []; 
  bool _isLoading = false;
  bool _isFetchingMore = false; 
  int _currentPage = 1;
  bool _hasNextPage = true; 
  String? _errorMessage;

  final TokenStorage _tokenStorage = TokenStorage();

  AllShoutModel? get shouts => _shouts;
  List<ShoutModel> get shoutsList => _allShoutsList; 
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllShouts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _allShoutsList.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _loadPosts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreShouts() async {
    if (_isFetchingMore || !_hasNextPage) return;

    _isFetchingMore = true;
    _currentPage++;
    notifyListeners();

    await _loadPosts();

    _isFetchingMore = false;
    notifyListeners();
  }

  Future<void> _loadPosts() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = "Authentication token not found";
        return;
      }

      final url = "${ApiEndPoints.shout}?page=$_currentPage";
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        final newShouts = AllShoutModel.fromJson(decodedData);

    
        if (newShouts.data != null && newShouts.data!.isNotEmpty) {
          _shouts = newShouts;
          _allShoutsList.addAll(newShouts.data!);  
        } else {
          _hasNextPage = false; 
        }
      } else {
        _errorMessage = "Error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Connection Error: $e";
    }
  }
}