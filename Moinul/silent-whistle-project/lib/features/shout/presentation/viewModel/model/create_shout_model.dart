class ShoutModel {
  String? id;
  String? createdAt;
  String? status;
  String? content;
  String? category;
  String? location;
  bool isAnonymous;
  User? user;
  List<Medias>? medias;
  bool isLiked;
  int likesCount;
  int commentsCount;
  int sharesCount;

  ShoutModel({
    this.id,
    this.createdAt,
    this.status,
    this.content,
    this.category,
    this.location,
    this.isAnonymous = false,
    this.user,
    this.medias,
    this.isLiked = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
  });

  factory ShoutModel.fromJson(Map<String, dynamic> json) {
    return ShoutModel(
      id: json['id'],
      createdAt: json['created_at'],
      status: json['status'],
      content: json['content'],
      category: json['category'],
      location: json['location'],
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1 || json['is_anonymous'] == 'true',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      medias: json['medias'] != null 
          ? List<Medias>.from(json['medias'].map((x) => Medias.fromJson(x))) 
          : null,
      isLiked: json['is_liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
    );
  }
}

class User {
  String? id;
  String? name;
  String? username;
  String? avatar;

  User({this.id, this.name, this.username, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    avatar = json['avatar'];
  }
}

class Medias {
  String? id;
  String? type;
  String? url;
  String? duration;

  Medias({this.id, this.type, this.url, this.duration});

  Medias.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    url = json['url'];
    duration = json['duration'];
  }
}