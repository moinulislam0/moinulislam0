import 'package:flutter/material.dart';
import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:jwells/features/auth/model_view/shout_provider.dart';
import 'package:jwells/features/home/presentation/view/widgets/postCard.dart'; 
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String shoutId;
  final String postId; 

  const PostDetailScreen({super.key, required this.shoutId, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoutProvider>().fetchAllShouts();
    });
  }

  String calculateTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Just now";
    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      final Duration diff = DateTime.now().difference(date);
      if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y ago';
      if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return "Just now";
    }
  }

  PostType getPostType(String? category) {
    if (category == null) return PostType.Idea;
    switch (category.toLowerCase()) {
      case 'observation': return PostType.Obervation;
      case 'concern': return PostType.Concern;
      case 'thought': return PostType.Thought;
      case 'gratitude': return PostType.Gratitude;
      case 'gossip': return PostType.Gossip;
      default: return PostType.Idea;
    }
  }


  Map<String, dynamic> _extractMedia(dynamic item) {
    List<String> images = [];
    String? voice;
    String? duration;

    if (item.medias != null) {
      for (var m in item.medias!) {
        if (m.type == "IMAGE" && m.url != null) {
          images.add(m.url!);
        }
        if ((m.type == "AUDIO" || m.type == "VOICE") && m.url != null) {
          voice = m.url;
          duration = m.duration;
        }
      }
    }
    return {'images': images, 'voice': voice, 'duration': duration};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("Post Details", style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ShoutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF38E07B)));
          }

          final postData = provider.shouts?.data?.where(
            (element) => element.id.toString() == widget.shoutId.toString(),
          ).toList();

          if (postData == null || postData.isEmpty) {
            return const Center(child: Text("Post not found", style: TextStyle(color: Colors.white54)));
          }

          final item = postData.first;
          final media = _extractMedia(item);

        
          Post? originalPostData;
          if (item.originalShout != null) {
            final origMedia = _extractMedia(item.originalShout);
            final originalIsMasked = AppFeatureFlags.shouldMaskIdentity(
              item.originalShout!.isAnonymous == true,
            );
            originalPostData = Post(
              id: item.originalShout!.id?.toString() ?? "",
              userName: originalIsMasked
                  ? "Anonymous"
                  : (item.originalShout!.user?.name ?? "Unknown"),
              userAvatar: originalIsMasked
                  ? ""
                  : (item.originalShout!.user?.avatar ?? ""),
              timeAgo: calculateTimeAgo(item.originalShout!.createdAt),
              location: item.originalShout!.location ?? "Global",
              type: getPostType(item.originalShout!.category),
              content: item.originalShout!.content ?? "",
              imageUrls: origMedia['images'].isNotEmpty ? origMedia['images'] : null,
              voiceUrl: origMedia['voice'],
              voiceDuration: origMedia['duration'],
              likes: item.originalShout!.likesCount?.toInt() ?? 0,
              comments: item.originalShout!.commentsCount?.toInt() ?? 0,
              shares: item.originalShout!.sharesCount?.toInt() ?? 0,
              isAlreadyLiked: item.originalShout!.isLiked ?? false,
            );
          }

          final itemIsMasked = AppFeatureFlags.shouldMaskIdentity(
            item.isAnonymous == true,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: PostCard(
              post: Post(
                id: item.id?.toString() ?? "",
                userName: itemIsMasked
                    ? "Anonymous"
                    : (item.user?.name ?? "Unknown"),
                userAvatar: itemIsMasked ? "" : (item.user?.avatar ?? ""),
                timeAgo: calculateTimeAgo(item.createdAt),
                location: item.location ?? "Global",
                type: getPostType(item.category),
                content: item.content ?? "", 
                imageUrls: media['images'].isNotEmpty ? media['images'] : null, 
                voiceUrl: media['voice'], 
                voiceDuration: media['duration'],
                likes: item.likesCount?.toInt() ?? 0,
                comments: item.commentsCount?.toInt() ?? 0,
                shares: item.sharesCount?.toInt() ?? 0,
                isAlreadyLiked: item.isLiked ?? false,
                userId: item.user?.id,
                isAnonymous: itemIsMasked,
                originalPost: originalPostData, 
              ),
              onRefresh: () => provider.fetchAllShouts(),
            ),
          );
        },
      ),
    );
  }
}
