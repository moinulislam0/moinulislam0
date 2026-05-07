// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:jwells/core/constant/api_endpoints.dart';
// import 'package:jwells/core/services/api_services/api_services.dart';

// import '../../data/models/subscription_plans_response.dart';

// class SubscriptionProvider extends ChangeNotifier {
//   final ApiService _apiService;

//   SubscriptionProvider(this._apiService);

//   // Loading states
//   bool _isLoading = false;
//   bool _isProcessing = false;
//   bool _isStartingTrial = false;
//   bool _isChargingCard = false;
//   bool _isVerifyingOtp = false;

//   // Data
//   String? _errorMessage;
//   List<SubscriptionPlan> _plans = [];
//   SubscriptionPlan? _selectedPlan;
//   StartTrialResponse? _trialResponse;
//   PaymentChargeResponse? _paymentResponse;

//   // Getters
//   bool get isLoading => _isLoading;
//   bool get isProcessing => _isProcessing;
//   bool get isStartingTrial => _isStartingTrial;
//   bool get isChargingCard => _isChargingCard;
//   bool get isVerifyingOtp => _isVerifyingOtp;
//   String? get errorMessage => _errorMessage;
//   List<SubscriptionPlan> get plans => _plans;
//   SubscriptionPlan? get selectedPlan => _selectedPlan;
//   StartTrialResponse? get trialResponse => _trialResponse;
//   PaymentChargeResponse? get paymentResponse => _paymentResponse;

//   // Specific Plans Getters
//   List<SubscriptionPlan> get premiumPlans => _plans.where((p) => p.isPremiumPlan).toList();
//   SubscriptionPlan? get trialPlan => _plans.firstWhere((p) => p.isTrialPlan, orElse: () => _plans.first);

//   // ============================================
//   // 1. GET ALL PLANS
//   // ============================================
//   Future<bool> getAllPlans({bool refresh = false}) async {
//     if (_isProcessing && !refresh) {
//       debugPrint('⚠️ Plans fetch already in progress, ignoring duplicate call');
//       return false;
//     }

//     try {
//       if (refresh) _plans.clear();
//       _isProcessing = true;
//       _isLoading = refresh || _plans.isEmpty;
//       _errorMessage = null;
//       notifyListeners();

//       debugPrint('🔵 Fetching subscription plans');

//       final response = await _apiService.get(ApiEndPoints.getAllPlans);

//       debugPrint('📥 Response Status: ${response.statusCode}');
//       debugPrint('📥 Response Data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final plansResponse = SubscriptionPlansResponse.fromJson(response.data);

//         if (plansResponse.success == true && plansResponse.plans != null) {
//           _plans = plansResponse.plans!;
//           _errorMessage = null;
//           debugPrint('✅ Plans loaded successfully: ${_plans.length} plans');
//           return true;
//         } else {
//           _errorMessage = 'Failed to load plans';
//           debugPrint('❌ Invalid plans data structure');
//           return false;
//         }
//       } else if (response.statusCode == 400) {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Bad request';
//         debugPrint('❌ Status 400: $_errorMessage');
//         return false;
//       } else if (response.statusCode == 401) {
//         _errorMessage = 'Unauthorized. Please login again';
//         debugPrint('❌ Status 401: Unauthorized');
//         return false;
//       } else if (response.statusCode == 404) {
//         _errorMessage = 'Plans not found';
//         debugPrint('❌ Status 404: Plans not found');
//         return false;
//       } else if (response.statusCode == 500) {
//         _errorMessage = 'Server error. Please try again later';
//         debugPrint('❌ Status 500: Server error');
//         return false;
//       } else {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Failed to load plans';
//         debugPrint('❌ Status ${response.statusCode}: $_errorMessage');
//         return false;
//       }
//     } on DioException catch (e) {
//       debugPrint('❌ DioException: ${e.type}');
//       debugPrint('❌ Response: ${e.response?.data}');

//       _errorMessage = _handleDioException(e);
//       return false;
//     } catch (e) {
//       debugPrint('❌ Unexpected error: $e');
//       _errorMessage = 'An unexpected error occurred';
//       return false;
//     } finally {
//       _isLoading = false;
//       _isProcessing = false;
//       notifyListeners();
//       debugPrint('🔵 Plans fetch completed');
//     }
//   }

//   // ============================================
//   // 2. START FREE TRIAL
//   // ============================================
//   Future<bool> startTrial() async {
//     if (_isStartingTrial) {
//       debugPrint('⚠️ Trial start already in progress');
//       return false;
//     }

//     try {
//       _isStartingTrial = true;
//       _errorMessage = null;
//       notifyListeners();

//       debugPrint('🔵 Starting free trial');

//       final response = await _apiService.post(ApiEndPoints.startTrial, data: {});

//       debugPrint('📥 Response Status: ${response.statusCode}');
//       debugPrint('📥 Response Data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _trialResponse = StartTrialResponse.fromJson(response.data);

//         if (_trialResponse?.success == true) {
//           _errorMessage = null;
//           debugPrint('✅ Trial started successfully');
//           return true;
//         } else {
//           _errorMessage = _trialResponse?.message ?? 'Failed to start trial';
//           debugPrint('❌ Trial start failed: $_errorMessage');
//           return false;
//         }
//       } else if (response.statusCode == 400) {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Bad request';
//         debugPrint('❌ Status 400: $_errorMessage');
//         return false;
//       } else if (response.statusCode == 401) {
//         _errorMessage = 'Unauthorized. Please login again';
//         debugPrint('❌ Status 401: Unauthorized');
//         return false;
//       } else if (response.statusCode == 409) {
//         _errorMessage = 'Trial already started or expired';
//         debugPrint('❌ Status 409: Conflict');
//         return false;
//       } else if (response.statusCode == 500) {
//         _errorMessage = 'Server error. Please try again later';
//         debugPrint('❌ Status 500: Server error');
//         return false;
//       } else {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Failed to start trial';
//         debugPrint('❌ Status ${response.statusCode}: $_errorMessage');
//         return false;
//       }
//     } on DioException catch (e) {
//       debugPrint('❌ DioException: ${e.type}');
//       debugPrint('❌ Response: ${e.response?.data}');

//       _errorMessage = _handleDioException(e);
//       return false;
//     } catch (e) {
//       debugPrint('❌ Unexpected error: $e');
//       _errorMessage = 'An unexpected error occurred';
//       return false;
//     } finally {
//       _isStartingTrial = false;
//       notifyListeners();
//       debugPrint('🔵 Trial start completed');
//     }
//   }

//   // ============================================
//   // 3. CHARGE CARD (Premium Payment with Card)
//   // ============================================
//   Future<bool> chargeCard({
//     required String planId,
//     required String cardNumber,
//     required String cvv,
//     required String expiryMonth,
//     required String expiryYear,
//     String? pin,
//   }) async {
//     if (_isChargingCard) {
//       debugPrint('⚠️ Card charge already in progress');
//       return false;
//     }

//     try {
//       _isChargingCard = true;
//       _errorMessage = null;
//       notifyListeners();

//       // Clean card number (remove spaces)
//       final cleanCardNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');

//       final requestData = {
//         'planId': planId,
//         'cardNumber': cleanCardNumber,
//         'cvv': cvv,
//         'expiryMonth': expiryMonth,
//         'expiryYear': expiryYear,
//         if (pin != null && pin.isNotEmpty) 'pin': pin,
//       };

//       debugPrint('🔵 Charging card for plan: $planId');
//       debugPrint('🔵 Request Data: $requestData');

//       final response = await _apiService.post(
//         ApiEndPoints.chargeCard,
//         data: requestData,
//       );

//       debugPrint('📥 Response Status: ${response.statusCode}');
//       debugPrint('📥 Response Data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _paymentResponse = PaymentChargeResponse.fromJson(response.data);

//         // Check if OTP is required
//         if (response.data['requiresOtp'] == true ||
//             response.data['requires_otp'] == true ||
//             _paymentResponse?.data?.requiresOtp == true) {
//           if (_paymentResponse?.data != null) {
//             _paymentResponse!.data!.requiresOtp = true;
//           }
//           debugPrint('⚠️ OTP required for this transaction');
//         }

//         if (_paymentResponse?.success == true) {
//           _errorMessage = null;
//           debugPrint('✅ Card charged successfully');
//           return true;
//         } else {
//           _errorMessage = _paymentResponse?.message ?? 'Payment failed';
//           debugPrint('❌ Payment failed: $_errorMessage');
//           return false;
//         }
//       } else if (response.statusCode == 400) {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Invalid card details';
//         debugPrint('❌ Status 400: $_errorMessage');
//         return false;
//       } else if (response.statusCode == 401) {
//         _errorMessage = 'Unauthorized. Please login again';
//         debugPrint('❌ Status 401: Unauthorized');
//         return false;
//       } else if (response.statusCode == 402) {
//         _errorMessage = 'Payment required or insufficient funds';
//         debugPrint('❌ Status 402: Payment required');
//         return false;
//       } else if (response.statusCode == 422) {
//         _errorMessage = 'Invalid card information';
//         debugPrint('❌ Status 422: Validation error');
//         return false;
//       } else if (response.statusCode == 500) {
//         _errorMessage = 'Server error. Please try again later';
//         debugPrint('❌ Status 500: Server error');
//         return false;
//       } else {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Payment failed';
//         debugPrint('❌ Status ${response.statusCode}: $_errorMessage');
//         return false;
//       }
//     } on DioException catch (e) {
//       debugPrint('❌ DioException: ${e.type}');
//       debugPrint('❌ Response: ${e.response?.data}');

//       _errorMessage = _handleDioException(e);
//       return false;
//     } catch (e) {
//       debugPrint('❌ Unexpected error: $e');
//       _errorMessage = 'An unexpected error occurred';
//       return false;
//     } finally {
//       _isChargingCard = false;
//       notifyListeners();
//       debugPrint('🔵 Card charge completed');
//     }
//   }

//   // ============================================
//   // 4. VERIFY OTP
//   // ============================================
//   Future<bool> verifyOtp({
//     required String reference,
//     required String otp,
//   }) async {
//     if (_isVerifyingOtp) {
//       debugPrint('⚠️ OTP verification already in progress');
//       return false;
//     }

//     try {
//       _isVerifyingOtp = true;
//       _errorMessage = null;
//       notifyListeners();

//       final requestData = {
//         'reference': reference,
//         'otp': otp,
//       };

//       debugPrint('🔵 Verifying OTP');
//       debugPrint('🔵 Request Data: $requestData');

//       final response = await _apiService.post(
//         ApiEndPoints.subscriptionOtp,
//         data: requestData,
//       );

//       debugPrint('📥 Response Status: ${response.statusCode}');
//       debugPrint('📥 Response Data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final otpResponse = OtpVerificationResponse.fromJson(response.data);

//         if (otpResponse.success == true) {
//           _errorMessage = null;
//           debugPrint('✅ OTP verified successfully');
//           return true;
//         } else {
//           _errorMessage = otpResponse.message ?? 'OTP verification failed';
//           debugPrint('❌ OTP verification failed: $_errorMessage');
//           return false;
//         }
//       } else if (response.statusCode == 400) {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Invalid OTP';
//         debugPrint('❌ Status 400: $_errorMessage');
//         return false;
//       } else if (response.statusCode == 401) {
//         _errorMessage = 'Unauthorized. Please login again';
//         debugPrint('❌ Status 401: Unauthorized');
//         return false;
//       } else if (response.statusCode == 404) {
//         _errorMessage = 'Transaction not found';
//         debugPrint('❌ Status 404: Not found');
//         return false;
//       } else if (response.statusCode == 422) {
//         _errorMessage = 'Invalid or expired OTP';
//         debugPrint('❌ Status 422: Validation error');
//         return false;
//       } else if (response.statusCode == 500) {
//         _errorMessage = 'Server error. Please try again later';
//         debugPrint('❌ Status 500: Server error');
//         return false;
//       } else {
//         final message = response.data?['message'];
//         _errorMessage = message is String ? message : 'Verification failed';
//         debugPrint('❌ Status ${response.statusCode}: $_errorMessage');
//         return false;
//       }
//     } on DioException catch (e) {
//       debugPrint('❌ DioException: ${e.type}');
//       debugPrint('❌ Response: ${e.response?.data}');

//       _errorMessage = _handleDioException(e);
//       return false;
//     } catch (e) {
//       debugPrint('❌ Unexpected error: $e');
//       _errorMessage = 'An unexpected error occurred';
//       return false;
//     } finally {
//       _isVerifyingOtp = false;
//       notifyListeners();
//       debugPrint('🔵 OTP verification completed');
//     }
//   }

//   // ============================================
//   // Helper Methods
//   // ============================================

//   /// Handle DioException and return appropriate error message
//   String _handleDioException(DioException e) {
//     if (e.response != null) {
//       final statusCode = e.response?.statusCode;
//       final responseData = e.response?.data;

//       if (statusCode == 400) {
//         if (responseData is Map) {
//           final message = responseData['message'];
//           if (message is String) {
//             return message;
//           } else if (message is Map && message.containsKey('message')) {
//             return message['message'];
//           } else {
//             return 'Bad request';
//           }
//         } else {
//           return 'Bad request';
//         }
//       } else if (statusCode == 401) {
//         return 'Unauthorized. Please login again';
//       } else if (statusCode == 402) {
//         return 'Payment required or insufficient funds';
//       } else if (statusCode == 404) {
//         return 'Resource not found';
//       } else if (statusCode == 409) {
//         return 'Conflict: Operation already completed';
//       } else if (statusCode == 422) {
//         if (responseData is Map) {
//           final message = responseData['message'];
//           if (message is String) {
//             return message;
//           } else {
//             return 'Validation error';
//           }
//         } else {
//           return 'Validation error';
//         }
//       } else if (statusCode == 500) {
//         return 'Server error. Please try again later';
//       } else {
//         if (responseData is Map) {
//           final message = responseData['message'];
//           if (message is String) {
//             return message;
//           } else if (message is Map && message.containsKey('message')) {
//             return message['message'];
//           } else {
//             return 'Request failed';
//           }
//         } else {
//           return 'Request failed';
//         }
//       }
//     } else if (e.type == DioExceptionType.connectionTimeout) {
//       return 'Connection timeout. Please try again';
//     } else if (e.type == DioExceptionType.receiveTimeout) {
//       return 'Server is not responding. Please try again';
//     } else if (e.type == DioExceptionType.connectionError) {
//       return 'Network error. Please check your connection';
//     } else {
//       return 'Network error. Please check your connection';
//     }
//   }

//   void selectPlan(SubscriptionPlan plan) {
//     _selectedPlan = plan;
//     notifyListeners();
//     debugPrint('✅ Plan selected: ${plan.name}');
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//     debugPrint('🔵 Error cleared');
//   }

//   void resetPaymentResponse() {
//     _paymentResponse = null;
//     notifyListeners();
//     debugPrint('🔵 Payment response reset');
//   }

//   void reset() {
//     _isLoading = false;
//     _isProcessing = false;
//     _isStartingTrial = false;
//     _isChargingCard = false;
//     _isVerifyingOtp = false;
//     _errorMessage = null;
//     _plans.clear();
//     _selectedPlan = null;
//     _trialResponse = null;
//     _paymentResponse = null;
//     notifyListeners();
//     debugPrint('🔵 SubscriptionProvider reset');
//   }
// }