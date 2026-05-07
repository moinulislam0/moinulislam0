import 'package:jwells/features/shout/presentation/viewModel/model/create_shout_model.dart';

class ShoutModel {
  String? id;
  String? createdAt;
  String? status;
  String? content;
  String? category;
  String? location;
  bool? isAnonymous;
  User? user;
  List<Medias>? medias;
  bool? isLiked;
  int? likesCount;
  int? commentsCount;
  int? sharesCount;

 
  ShoutModel? originalShout;

  ShoutModel({
    this.id,
    this.createdAt,
    this.status,
    this.content,
    this.category,
    this.location,
    this.isAnonymous,
    this.user,
    this.medias,
    this.isLiked,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.originalShout,
  });

  ShoutModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    status = json['status'];
    content = json['content'];
    category = json['category'];
    location = json['location'];
    isAnonymous = json['is_anonymous'];

    user = json['user'] != null ? User.fromJson(json['user']) : null;

    if (json['medias'] != null) {
      medias = <Medias>[];
      json['medias'].forEach((v) {
        medias!.add(Medias.fromJson(v));
      });
    }

  
    isLiked = json['is_liked'] ?? false;
    likesCount = json['likes_count'] ?? 0;
    commentsCount = json['comments_count'] ?? 0;
    sharesCount = json['shares_count'] ?? 0;

    originalShout = json['original_shout'] != null
        ? ShoutModel.fromJson(json['original_shout'])
        : null;
  }
}
