import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/profile/data/model/blocked_user_model.dart';

class BlockedUsersProvider extends ChangeNotifier {
  final ApiService _apiService;

  BlockedUsersProvider(this._apiService);

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<BlockedUserModel> _blockedUsers = [];

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<BlockedUserModel> get blockedUsers => _blockedUsers;

  Future<bool> fetchBlockedUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndPoints.myBlockedUsers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final rawList = _extractUsersList(data);
        _blockedUsers = rawList
            .whereType<Map<String, dynamic>>()
            .map(BlockedUserModel.fromJson)
            .where((user) => user.id.isNotEmpty)
            .toList();
        return true;
      }

      _errorMessage =
          response.data['message']?.toString() ?? 'Failed to load blocked users.';
      return false;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message']?.toString() ??
          'Failed to load blocked users.';
      return false;
    } catch (_) {
      _errorMessage = 'Failed to load blocked users.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unblockUser(String userId) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndPoints.unblockUser,
        data: {'blocked_user_id': userId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _blockedUsers.removeWhere((user) => user.id == userId);
        _successMessage = response.data['message']?.toString() ??
            'User unblocked successfully.';
        return true;
      }

      _errorMessage =
          response.data['message']?.toString() ?? 'Failed to unblock user.';
      return false;
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data['message']?.toString() ?? 'Failed to unblock user.';
      return false;
    } catch (_) {
      _errorMessage = 'Failed to unblock user.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _extractUsersList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        for (final key in ['users', 'blockedUsers', 'blocked_users', 'items']) {
          final value = data[key];
          if (value is List) {
            return value;
          }
        }
      }

      for (final key in ['users', 'blockedUsers', 'blocked_users', 'items']) {
        final value = responseData[key];
        if (value is List) {
          return value;
        }
      }
    }

    return const [];
  }
}
