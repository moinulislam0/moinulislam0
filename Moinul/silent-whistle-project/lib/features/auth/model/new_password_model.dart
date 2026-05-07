class NewPasswordModel {
  String? email;
  String? otp;
  String? newPassword;

  NewPasswordModel({this.email, this.otp, this.newPassword});

  NewPasswordModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    otp = json['otp'];
    newPassword = json['new_password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['otp'] = this.otp;
    data['new_password'] = this.newPassword;
    return data;
  }
}