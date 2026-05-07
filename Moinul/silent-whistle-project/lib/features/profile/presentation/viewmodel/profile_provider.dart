import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

import '../../../../core/constant/api_endpoints.dart';
import '../../data/model/profile_response_model.dart';


class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService;

  ProfileProvider(this._apiService);

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  GetProfileResponseModel? _profileData;
  List<Posts> _posts = [];
  Profile? _profile;
  bool _requiresSubscription = false;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  int _selectedTabIndex = 0;
  final List<String> _rowTab = [
    'All',
    'Concerns',
    'Idea',
    'Gossip',
    'General',
    'Observation',
  ];

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  GetProfileResponseModel? get profileData => _profileData;
  List<Posts> get posts => _posts;
  Profile? get profile => _profile;
  bool get requiresSubscription => _requiresSubscription;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;
  int get selectedTabIndex => _selectedTabIndex;
  List<String> get rowTab => _rowTab;

  void selectRowTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<bool> getProfile(String userId, {bool refresh = false}) async {
    if (_isProcessing) {
      debugPrint('⚠️ Profile fetch already in progress, ignoring duplicate call');
      return false;
    }

    try {
      if (refresh) {
        _currentPage = 1;
        _posts.clear();
        _hasMoreData = true;
      }

      _isProcessing = true;
      _isLoading = refresh || _posts.isEmpty;
      _errorMessage = null;
      _requiresSubscription = false;
      notifyListeners();

      debugPrint('🔵 Fetching profile for user: $userId, page: $_currentPage');

      final response = await _apiService.get(
        ApiEndPoints.getProfile(_currentPage, _pageSize, userId),
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _profileData = GetProfileResponseModel.fromJson(response.data);

        if (_profileData?.success == true && _profileData?.data != null) {
          _profile = _profileData!.data!.profile;

          if (_profileData!.data!.posts != null) {
            final newPosts = _profileData!.data!.posts!;

            if (refresh) {
              _posts = newPosts;
            } else {
              for (var newPost in newPosts) {
                final exists = _posts.any((p) => p.id == newPost.id);
                if (!exists) {
                  _posts.add(newPost);
                }
              }
            }

            if (newPosts.length < _pageSize) {
              _hasMoreData = false;
            }
          } else {
            _hasMoreData = false;
          }

          _errorMessage = null;
          debugPrint('✅ Profile loaded successfully');
          return true;
        } else {
          _errorMessage = 'Failed to load profile data';
          debugPrint('❌ Invalid profile data structure');
          return false;
        }
      } else if (response.statusCode == 400) {
        final message = response.data?['message'];
        _errorMessage = message is String ? message : 'Bad request';
        debugPrint('❌ Status 400: $_errorMessage');
        return false;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again';
        debugPrint('❌ Status 401: Unauthorized');
        return false;
      } else if (response.statusCode == 403) {
        _requiresSubscription = true;
        final message = response.data?['message'];
        _errorMessage = message is String ? message : 'Subscription required';
        debugPrint('❌ Status 403: $_errorMessage');
        return false;
      } else if (response.statusCode == 404) {
        _errorMessage = 'Profile not found';
        debugPrint('❌ Status 404: Profile not found');
        return false;
      } else if (response.statusCode == 500) {
        _errorMessage = 'Server error. Please try again later';
        debugPrint('❌ Status 500: Server error');
        return false;
      } else {
        final message = response.data?['message'];
        _errorMessage = message is String ? message : 'Failed to load profile';
        debugPrint('❌ Status ${response.statusCode}: $_errorMessage');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}');
      debugPrint('❌ Response: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 400) {
          if (responseData is Map) {
            final message = responseData['message'];
            if (message is String) {
              _errorMessage = message;
            } else if (message is Map && message.containsKey('message')) {
              _errorMessage = message['message'];
            } else {
              _errorMessage = 'Bad request';
            }
          } else {
            _errorMessage = 'Bad request';
          }
        } else if (statusCode == 401) {
          _errorMessage = 'Unauthorized. Please login again';
        } else if (statusCode == 403) {
          _requiresSubscription = true;
          if (responseData is Map && responseData['message'] is String) {
            _errorMessage = responseData['message'] as String;
          } else {
            _errorMessage = 'Subscription required';
          }
        } else if (statusCode == 404) {
          _errorMessage = 'Profile not found';
        } else if (statusCode == 500) {
          _errorMessage = 'Server error. Please try again later';
        } else {
          if (responseData is Map) {
            final message = responseData['message'];
            if (message is String) {
              _errorMessage = message;
            } else if (message is Map && message.containsKey('message')) {
              _errorMessage = message['message'];
            } else {
              _errorMessage = 'Failed to load profile';
            }
          } else {
            _errorMessage = 'Failed to load profile';
          }
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
      debugPrint('🔵 Profile fetch completed, flags reset');
    }
  }

  Future<bool> loadMorePosts(String userId) async {
    if (_isLoadingMore || !_hasMoreData || _isLoading || _isProcessing) {
      debugPrint('⚠️ Cannot load more: isLoadingMore=$_isLoadingMore, hasMoreData=$_hasMoreData');
      return false;
    }

    try {
      _isLoadingMore = true;
      notifyListeners();

      _currentPage++;
      debugPrint('🔵 Loading more posts, page: $_currentPage');

      final response = await _apiService.get(
        ApiEndPoints.getProfile(_currentPage, _pageSize, userId),
      );

      debugPrint('📥 Load more - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newData = GetProfileResponseModel.fromJson(response.data);

        if (newData.success == true && newData.data?.posts != null) {
          final newPosts = newData.data!.posts!;

          for (var newPost in newPosts) {
            final exists = _posts.any((p) => p.id == newPost.id);
            if (!exists) {
              _posts.add(newPost);
            }
          }

          if (newPosts.length < _pageSize) {
            _hasMoreData = false;
          }

          debugPrint('✅ Loaded ${newPosts.length} more posts');
          return true;
        } else {
          _hasMoreData = false;
          _currentPage--;
          return false;
        }
      } else {
        _currentPage--;
        debugPrint('❌ Load more failed with status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      _currentPage--;
      debugPrint('❌ Load more DioException: ${e.type}');
      return false;
    } catch (e) {
      _currentPage--;
      debugPrint('❌ Load more error: $e');
      return false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
      debugPrint('🔵 Load more completed');
    }
  }

  Future<bool> refreshProfile(String userId) async {
    debugPrint('🔄 Refreshing profile');
    return await getProfile(userId, refresh: true);
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isProcessing = false;
    _errorMessage = null;
    _profileData = null;
    _posts.clear();
    _profile = null;
    _currentPage = 1;
    _hasMoreData = true;
    _isLoadingMore = false;
    _selectedTabIndex = 0;
    notifyListeners();
    debugPrint('🔵 ProfileProvider reset');
  }
}
