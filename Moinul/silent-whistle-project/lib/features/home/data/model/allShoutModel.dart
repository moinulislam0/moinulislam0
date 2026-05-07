

import 'package:jwells/features/auth/model/shoutModel.dart'; 
class AllShoutModel {
  bool? status;
  String? message;
  List<ShoutModel>? data; 

  AllShoutModel({this.status, this.message, this.data});

  AllShoutModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ShoutModel>[];
      json['data'].forEach((v) {
        data!.add(ShoutModel.fromJson(v)); 
      });
    }
  }
}