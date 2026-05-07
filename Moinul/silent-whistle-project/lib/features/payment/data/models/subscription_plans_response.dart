class SubscriptionPlansResponse {
  bool? success;
  int? statusCode;
  List<SubscriptionPlan>? plans;

  SubscriptionPlansResponse({this.success, this.statusCode, this.plans});

  SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    if (json['plans'] != null) {
      plans = <SubscriptionPlan>[];
      json['plans'].forEach((v) {
        plans!.add(SubscriptionPlan.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['statusCode'] = statusCode;
    if (plans != null) {
      data['plans'] = plans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionPlan {
  String? id;
  String? name;
  String? slug;
  String? description;
  String? priceDescription;
  bool? isFree;
  String? price;
  String? currency;
  String? interval;
  int? intervalCount;
  String? paystackPlanId;
  String? paystackPlanCode;
  int? trialDays;
  String? type;
  String? createdAt;
  String? updatedAt;

  SubscriptionPlan({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.priceDescription,
    this.isFree,
    this.price,
    this.currency,
    this.interval,
    this.intervalCount,
    this.paystackPlanId,
    this.paystackPlanCode,
    this.trialDays,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    priceDescription = json['price_description'];
    isFree = json['isFree'];
    price = json['price'];
    currency = json['currency'];
    interval = json['interval'];
    intervalCount = json['intervalCount'];
    paystackPlanId = json['paystackPlanId'];
    paystackPlanCode = json['paystackPlanCode'];
    trialDays = json['trialDays'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    data['price_description'] = priceDescription;
    data['isFree'] = isFree;
    data['price'] = price;
    data['currency'] = currency;
    data['interval'] = interval;
    data['intervalCount'] = intervalCount;
    data['paystackPlanId'] = paystackPlanId;
    data['paystackPlanCode'] = paystackPlanCode;
    data['trialDays'] = trialDays;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  // Helper getters
  bool get isTrialPlan => type?.toUpperCase() == 'TRIALING';
  bool get isPremiumPlan => type?.toUpperCase() == 'PREMIUM';

  int get priceInKobo => int.tryParse(price ?? '0') ?? 0;

  String get displayPrice {
    if (isFree == true || price == '0') return 'Free';
    return '₦${_formatPrice(price ?? '0')}';
  }

  String _formatPrice(String price) {
    final amount = int.tryParse(price) ?? 0;
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String get displayInterval {
    switch (interval?.toLowerCase()) {
      case 'monthly':
        return 'month';
      case 'quarterly':
        return '3 months';
      case 'biannually':
        return '6 months';
      case 'annually':
        return 'year';
      default:
        return interval ?? '';
    }
  }

  String get fullDisplayPrice {
    if (isFree == true || price == '0') return 'Free';
    return '$displayPrice/$displayInterval';
  }
}

// Start Trial Response Model
class StartTrialResponse {
  bool? success;
  int? statusCode;
  String? message;
  TrialData? data;

  StartTrialResponse({this.success, this.statusCode, this.message, this.data});

  StartTrialResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? TrialData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TrialData {
  String? startDate;
  String? endDate;

  TrialData({this.startDate, this.endDate});

  TrialData.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    return data;
  }
}

// Payment Charge Response Model
class PaymentChargeResponse {
  bool? success;
  int? statusCode;
  String? message;
  PaymentData? data;

  PaymentChargeResponse({this.success, this.statusCode, this.message, this.data});

  PaymentChargeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? PaymentData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PaymentData {
  String? authorizationUrl;
  String? accessCode;
  String? reference;
  bool? requiresOtp;
  String? status;

  PaymentData({
    this.authorizationUrl,
    this.accessCode,
    this.reference,
    this.requiresOtp,
    this.status,
  });

  PaymentData.fromJson(Map<String, dynamic> json) {
    authorizationUrl = json['authorization_url'];
    accessCode = json['access_code'];
    reference = json['reference'];
    requiresOtp = json['requiresOtp'] ?? json['requires_otp'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['authorization_url'] = authorizationUrl;
    data['access_code'] = accessCode;
    data['reference'] = reference;
    data['requiresOtp'] = requiresOtp;
    data['status'] = status;
    return data;
  }
}

// OTP Verification Response Model
class OtpVerificationResponse {
  bool? success;
  int? statusCode;
  String? message;

  OtpVerificationResponse({this.success, this.statusCode, this.message});

  OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}