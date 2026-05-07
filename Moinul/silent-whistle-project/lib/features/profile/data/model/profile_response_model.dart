class GetProfileResponseModel {
  bool? success;
  int? statusCode;
  Data? data;

  GetProfileResponseModel({this.success, this.statusCode, this.data});

  GetProfileResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Profile? profile;
  List<Posts>? posts;

  Data({this.profile, this.posts});

  Data.fromJson(Map<String, dynamic> json) {
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    if (json['posts'] != null) {
      posts = <Posts>[];
      json['posts'].forEach((v) {
        posts!.add(new Posts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    if (this.posts != null) {
      data['posts'] = this.posts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Profile {
  String? id;
  String? name;
  String? username;
  String? avatar;
  String? about;
  String? country;
  String? city;
  String? state;
  String? createdAt;

  Profile(
      {this.id,
        this.name,
        this.username,
        this.avatar,
        this.about,
        this.country,
        this.city,
        this.state,
        this.createdAt});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    avatar = json['avatar'];
    about = json['about'];
    country = json['country'];
    city = json['city'];
    state = json['state'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    data['about'] = this.about;
    data['country'] = this.country;
    data['city'] = this.city;
    data['state'] = this.state;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Posts {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? status;
  String? content;
  String? category;
  String? location;
  String? latitude;
  String? longitude;
  bool? isAnonymous;
  String? userId;
  String? originalShoutId;
  Posts? originalShout; // ✅ NEW: Added originalShout field
  User? user;
  List<Medias>? medias;
  bool? isLiked;
  int? likesCount;
  int? commentsCount;
  int? sharesCount;

  Posts({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.status,
    this.content,
    this.category,
    this.location,
    this.latitude,
    this.longitude,
    this.isAnonymous,
    this.userId,
    this.originalShoutId,
    this.originalShout, // ✅ NEW: Added to constructor
    this.user,
    this.medias,
    this.isLiked,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
  });

  Posts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    status = json['status'];
    content = json['content'];
    category = json['category'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isAnonymous = json['is_anonymous'];
    userId = json['user_id'];
    originalShoutId = json['original_shout_id'];

    // ✅ NEW: Parse originalShout recursively
    originalShout = json['original_shout'] != null
        ? Posts.fromJson(json['original_shout'])
        : null;

    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['medias'] != null) {
      medias = <Medias>[];
      json['medias'].forEach((v) {
        medias!.add(new Medias.fromJson(v));
      });
    }
    isLiked = json['is_liked'];
    likesCount = json['likes_count'];
    commentsCount = json['comments_count'];
    sharesCount = json['shares_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['status'] = this.status;
    data['content'] = this.content;
    data['category'] = this.category;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['is_anonymous'] = this.isAnonymous;
    data['user_id'] = this.userId;
    data['original_shout_id'] = this.originalShoutId;

    // ✅ NEW: Serialize originalShout
    if (this.originalShout != null) {
      data['original_shout'] = this.originalShout!.toJson();
    }

    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.medias != null) {
      data['medias'] = this.medias!.map((v) => v.toJson()).toList();
    }
    data['is_liked'] = this.isLiked;
    data['likes_count'] = this.likesCount;
    data['comments_count'] = this.commentsCount;
    data['shares_count'] = this.sharesCount;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    return data;
  }
}

class Medias {
  String? id;
  String? createdAt;
  String? type;
  String? url;
  String? duration;
  String? shoutId;

  Medias(
      {this.id,
        this.createdAt,
        this.type,
        this.url,
        this.duration,
        this.shoutId});

  Medias.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    type = json['type'];
    url = json['url'];
    duration = json['duration'];
    shoutId = json['shout_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['type'] = this.type;
    data['url'] = this.url;
    data['duration'] = this.duration;
    data['shout_id'] = this.shoutId;
    return data;
  }
}