class SingUpModel {
  String? name;
  String? email;
  String? username;
  String? password;
  String? type;
  double? latitude;
  double? longitude;
  

  SingUpModel(
      {this.name,
      this.email,
      this.username,
      this.password,
      this.type,
      this.latitude,
      this.longitude});

   SingUpModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    username = json['username'];
    password = json['password'];
    type = json['type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['username'] = this.username;
    data['password'] = this.password;
    data['type'] = this.type;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}