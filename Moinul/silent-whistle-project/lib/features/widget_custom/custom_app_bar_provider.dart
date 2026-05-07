import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/auth/model/check_me_model.dart' hide Data;
import 'package:jwells/features/payment/presentation/view/screens/revenuecat_service.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBarProvider with ChangeNotifier {
  final ApiService _apiService;

  CustomAppBarProvider(ApiService apiService) : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;

  CustomAppBarModel? _model;
  Data? _data;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CustomAppBarModel? get model => _model;
  Data? get data => _data;
  bool ? _ispremimum;
  bool ? get isPremimum => _ispremimum;

  Future<bool> fetchAppBar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ispremimum= await RevenuecatService.isUserPremium();
      final response = await _apiService.get(ApiEndPoints.checkme);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;

        if (body is Map && body['success'] == false) {
          _errorMessage = body['message'] ?? 'Failed to load user';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _model = CustomAppBarModel.fromJson(body);

        _data = _model?.data;

        if (_data == null) {
          _errorMessage = 'No user data found';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load user. Status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Network error';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _model = null;
    _data = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Basic getters
  String? get id => data?.id;
  String? get name => _data?.name;
  String? get email => _data?.email;
  String? get avatar => _data?.avatar;
  String? get username => _data?.username;
  bool get hasUser => _data != null;

  // ============================================
  // SUBSCRIPTION PLAN CHECK METHODS
  // ============================================

  /// Check if user has an active subscription
  bool hasActiveSubscription() {
    return _data?.subscription?.isActive == true;
  }

  /// Check if user has PRO plan
  bool hasProPlan() {
    final planType = _data?.subscription?.plan?.type?.toUpperCase();
    return planType == 'PRO' && hasActiveSubscription();
  }

  /// Check if user has FREE plan (or no plan)
  bool hasFreePlan() {
    final planType = _data?.subscription?.plan?.type?.toUpperCase();
    return planType == 'FREE' ||
        planType == null ||
        !hasActiveSubscription();
  }

  /// Check if user is on TRIALING plan
  bool hasTrialPlan() {
    final planType = _data?.subscription?.plan?.type?.toUpperCase();
    return planType == 'TRIALING' && hasActiveSubscription();
  }

  /// Get subscription status (ACTIVE, TRIALING, EXPIRED, etc.)
  String? getSubscriptionStatus() {
    return _data?.subscription?.status;
  }

  /// Get subscription type
  String? getSubscriptionType() {
    return _data?.subscription?.type;
  }

  /// Get plan name (e.g., "30 Days Free Trial", "Pro Monthly")
  String? getPlanName() {
    return _data?.subscription?.plan?.name;
  }

  /// Get remaining days in subscription
  int? getRemainingDays() {
    return _data?.subscription?.remainingDays;
  }

  /// Check if subscription is expiring soon (less than 7 days)
  bool isExpiringSoon() {
    final remainingDays = getRemainingDays();
    return remainingDays != null && remainingDays < 7 && remainingDays > 0;
  }

  /// Check if subscription has expired
  bool hasExpired() {
    final remainingDays = getRemainingDays();
    return remainingDays != null && remainingDays <= 0;
  }

  /// Get formatted subscription info for UI display
  String getSubscriptionDisplayText() {
    if (!hasActiveSubscription()) {
      return 'No Active Subscription';
    }

    final planName = getPlanName() ?? 'Unknown Plan';
    final remainingDays = getRemainingDays();

    if (remainingDays != null && remainingDays > 0) {
      return '$planName ($remainingDays days left)';
    }

    return planName;
  }

  /// Check if user can access premium features
  bool canAccessPremiumFeatures() {
    return hasProPlan() || hasTrialPlan();
  }

  // Set error manually
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}