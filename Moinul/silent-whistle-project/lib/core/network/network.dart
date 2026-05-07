import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../app/config/app_config.dart';
import '../../features/payment/presentation/view/screens/revenuecat_service.dart';
import '../services/local_storage_service/token_storage.dart';

class Network {
  static final Network _instance = Network._internal();
  factory Network() => _instance;
  late Dio dio;

  Network._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio = Dio(options);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage().getToken();
        debugPrint('Injected Token: $token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        final String message = responseData is Map
            ? (responseData['message']?.toString() ?? '')
            : '';
        final bool isSubscriptionExpired = statusCode == 403 &&
            message.toLowerCase().contains('subscription expired');
        final bool retryDone =
            error.requestOptions.extra['subscriptionRetryDone'] == true;

        if (isSubscriptionExpired && !retryDone) {
          final bool synced =
              await RevenuecatService.syncSubscriptionStatusWithBackend();

          if (synced) {
            try {
              final requestOptions = error.requestOptions;
              requestOptions.extra['subscriptionRetryDone'] = true;
              final retryResponse = await dio.fetch(requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              // If retry still fails, continue with original error.
            }
          }
        }

        return handler.next(error);
      },
    ));
  }

}
