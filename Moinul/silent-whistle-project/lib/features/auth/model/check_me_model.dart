class CheckMeModel {
  bool? success;
  Data? data;

  CheckMeModel({this.success, this.data});

  CheckMeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    data['about'] = this.about;
    data['address'] = this.address;
    data['phone_number'] = this.phoneNumber;
    data['type'] = this.type;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['created_at'] = this.createdAt;
    return data;
  }
}
