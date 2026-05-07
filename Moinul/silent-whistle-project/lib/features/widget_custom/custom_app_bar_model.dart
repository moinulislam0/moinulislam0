class CustomAppBarModel {
  bool? success;
  int? statusCode;
  Data? data;

  CustomAppBarModel({this.success, this.statusCode, this.data});

  CustomAppBarModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? name;
  String? email;
  String? username;
  String? avatar;
  String? about;
  String? address;
  String? phoneNumber;
  String? type;
  String? gender;
  String? dateOfBirth;
  String? createdAt;
  bool? status; 
  Subscription? subscription;

  Data({
    this.id,
    this.name,
    this.email,
    this.username,
    this.avatar,
    this.about,
    this.address,
    this.phoneNumber,
    this.type,
    this.gender,
    this.dateOfBirth,
    this.createdAt,
    this.status,
    this.subscription,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    avatar = json['avatar'];
    about = json['about'];
    address = json['address'];
    phoneNumber = json['phone_number'];
    type = json['type'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    createdAt = json['created_at'];

    if (json['status'] is String) {
      status = json['status'] == "ACTIVE";
    } else {
      status = json['status'] ?? false;
    }

    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['username'] = username;
    data['avatar'] = avatar;
    data['about'] = about;
    data['address'] = address;
    data['phone_number'] = phoneNumber;
    data['type'] = type;
    data['gender'] = gender;
    data['date_of_birth'] = dateOfBirth;
    data['created_at'] = createdAt;
    
  
    data['status'] = (status == true) ? "ACTIVE" : "INACTIVE";

    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    return data;
  }
}

class Subscription {
  String? id;
  String? status;
  bool? isActive;
  String? type;
  int? remainingDays;
  Plan? plan;

  Subscription({
    this.id,
    this.status,
    this.isActive,
    this.type,
    this.remainingDays,
    this.plan,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    isActive = json['isActive'];
    type = json['type'];
    remainingDays = json['remainingDays'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['isActive'] = isActive;
    data['type'] = type;
    data['remainingDays'] = remainingDays;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    return data;
  }
}

class Plan {
  String? id;
  String? name;
  String? type;
  String? price;
  String? currency;
  String? interval;
  int? intervalCount;

  Plan({
    this.id,
    this.name,
    this.type,
    this.price,
    this.currency,
    this.interval,
    this.intervalCount,
  });

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    price = json['price'];
    currency = json['currency'];
    interval = json['interval'];
    intervalCount = json['intervalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['price'] = price;
    data['currency'] = currency;
    data['interval'] = interval;
    data['intervalCount'] = intervalCount;
    return data;
  }
}