enum PostType { Idea, Obervation, Thought, Gratitude, Concern, Gossip }

class Post {
  final String id;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String location;
  final String? category;
  final PostType type; 
  final String content;
  final List<String>? imageUrls; 
  final String? voiceUrl;
  final String? videoUrl;
  final String? voiceDuration;
  final int likes;
  final int comments;
  final int shares;
  final bool isAlreadyLiked;
  final String? userId;
  final bool isAnonymous;
  final String ?longitude;
  final String ?latitude;
  final Post? originalPost; 

  Post({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    this.category,

    required this.type,
    required this.content,
    this.imageUrls,
    this.voiceUrl,
    this.videoUrl,
    this.voiceDuration,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isAlreadyLiked,
    this.userId,
    this.isAnonymous = false,
    this.originalPost, this.longitude,  this.latitude,
  });
}
class CommentObj {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final String timeAgo;
  final String? parentId;
  final int likes;
  final List<CommentObj> replies;
  final int repliesCount;
  final bool isLiked; 

  CommentObj({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timeAgo,
    this.parentId,
    this.likes = 0,
    this.replies = const [],
    this.repliesCount = 0,
    this.isLiked = false, 
  });

  factory CommentObj.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return CommentObj(
      id: json['id']?.toString() ?? '',
      userName: user['name']?.toString() ?? 'Anonymous',
      userAvatar: user['avatar']?.toString() ?? 'https://i.pravatar.cc/150',
      content: json['content']?.toString() ?? '',
      timeAgo: json['created_at']?.toString() ?? 'Just now',
      likes: json['likes_count'] ?? 0,
      parentId: json['parent_id']?.toString(),
      repliesCount: json['replies_count'] ?? 0,
      isLiked: json['is_liked'] ?? false, 
      replies: (json['replies'] as List<dynamic>?)
              ?.map((replyJson) => CommentObj.fromJson(replyJson as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  CommentObj copyWith({List<CommentObj>? replies, int? repliesCount, bool? isLiked}) {
    return CommentObj(
      id: id,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      timeAgo: timeAgo,
      likes: likes,
      parentId: parentId,
      repliesCount: repliesCount ?? this.repliesCount,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
