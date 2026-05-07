import 'dart:developer';
import 'dart:io';

import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';


class RevenuecatService {

  static const _appleApiKey = 'appl_RyauChQkinTXxqgpdAxmMjXGYCF';
  static const _googleApiKey = 'goog_IRzcYJGijGifxpqBAbEvzyeaqoh';
  static const _premiumEntitlementId = 'com.john.jwells.weekly';


  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    } else {
      return; 
    }

    try {
      await Purchases.configure(configuration);
      log("RevenueCat: Initialized Successfully");
    } catch (e) {
      log("RevenueCat: Initialization Error: $e");
    }
  }


  static Future<Offerings?> getOfferings() async {
    try {
  
      return await Purchases.getOfferings();
    } catch (e) {
      log("RevenueCat: Error fetching offerings: $e");
      return null;
    }
  }

 
  static Future<bool> purchasePackage(Package package) async {
    try {
      final params = PurchaseParams.package(package);
      final result = await Purchases.purchase(params);

      final bool isPremium =
          result.customerInfo.entitlements.all[_premiumEntitlementId]
                  ?.isActive ??
              false;

      if (isPremium) {
        await _syncSubscriptionWithBackend(result.customerInfo, package);
      }

      return isPremium;
    } catch (e) {
      log("RevenueCat: Purchase failed: $e");
      return false;
    }
  }

  
  static Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final isPremium =
          info.entitlements.all[_premiumEntitlementId]?.isActive ?? false;
      if (isPremium) {
        await _syncSubscriptionWithBackend(info, null);
      }
      return info;
    } catch (e) {
      log("RevenueCat: Restore failed: $e");
      return null;
    }
  }

  static Future<bool> isUserPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      return customerInfo.entitlements.all[_premiumEntitlementId]?.isActive ??
          false;
    } catch (e) {
      log("Error checking status: $e");
      return false;
    }
  }

  static Future<bool> syncSubscriptionStatusWithBackend() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isPremium =
          info.entitlements.all[_premiumEntitlementId]?.isActive ?? false;

      if (isPremium) {
        await _syncSubscriptionWithBackend(info, null);
      }

      return isPremium;
    } catch (e) {
      log('RevenueCat: Subscription sync check failed: $e');
      return false;
    }
  }

  static Future<void> _syncSubscriptionWithBackend(
    CustomerInfo info,
    Package? package,
  ) async {
    try {
      final productId = package?.storeProduct.identifier ??
          (info.activeSubscriptions.isNotEmpty
              ? info.activeSubscriptions.first
              : null);
      final productTitle = package?.storeProduct.title;

      final payload = <String, dynamic>{
        'productId': productId,
        'productTitle': productTitle,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'appUserId': info.originalAppUserId,
        'activeEntitlements': info.entitlements.all.keys.toList(),
        'latestPurchaseDate': info.latestExpirationDate?.toString(),
        'transactionId': info.activeSubscriptions.isNotEmpty
            ? info.activeSubscriptions.first
            : null,
      };

      await ApiService().post(
        ApiEndPoints.verifySubscription,
        data: payload,
      );

      log('RevenueCat: Backend subscription sync completed');
    } catch (e) {
      log('RevenueCat: Backend subscription sync failed: $e');
    }
  }
}
