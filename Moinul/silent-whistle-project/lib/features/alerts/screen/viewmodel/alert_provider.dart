import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/alerts/data/model/notify_model.dart';

class AlertProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<NotificationModel> _notifications = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications => _notifications;
  String? get error => _error;

  // fetchNotifications method
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading = true; 
      notifyListeners();
    }
    
    _error = null;

    try {
      final response = await _apiService.get(ApiEndPoints.notification);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List rawData = response.data['data'] ?? [];
        _notifications = rawData.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        _error = "Failed to load notifications";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void removeNotificationLocally(String id) {
    _notifications.removeWhere((noti) => noti.id.toString() == id);
    notifyListeners(); 
  }
}