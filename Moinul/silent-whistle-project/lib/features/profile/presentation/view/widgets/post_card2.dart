import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:jwells/features/profile/presentation/view/screens/shout_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

// Import your providers here
import 'package:jwells/features/home/presentation/provider_model/comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/post_interaction_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/reply_comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/load_reply_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/share_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/like_comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/unlike_comment_provider.dart';
import 'package:jwells/features/home/presentation/view/widgets/voice_player_widget.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';

import '../../../../widget_custom/custom_app_bar_provider.dart';
import '../../viewmodel/profile_provider.dart';
import '../../viewmodel/shout_delete_provider.dart';

class PostCard2 extends StatefulWidget {
  final Post post;
  final VoidCallback? onRefresh;
  final Function(String originalPostId)? onOriginalPostTap;

  const PostCard2({
    super.key,
    required this.post,
    this.onRefresh,
    this.onOriginalPostTap,
  });

  @override
  State<PostCard2> createState() => _PostCard2State();
}

class _PostCard2State extends State<PostCard2> {
  bool isExpanded = false;
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  String? _activeReplyCommentId;
  late int currentCommentCount;

  // --- Logic for Optimistic Comment Likes ---
  final Set<String> _locallyLikedCommentIds = {};
  final Set<String> _locallyUnlikedCommentIds = {};
  final Map<String, int> _localCommentLikesCount = {};

  late PostInteractionProvider _postInteractionProvider;
  late CommentProvider _commentProvider;
  late ReplyCommentProvider _replyCommentProvider;

  @override
  void initState() {
    super.initState();
    currentCommentCount = widget.post.comments;

    _postInteractionProvider = PostInteractionProvider(
      isLiked: widget.post.isAlreadyLiked,
      likeCount: widget.post.likes,
    );
    _commentProvider = CommentProvider();
    _replyCommentProvider = ReplyCommentProvider();
  }

  @override
  void didUpdateWidget(PostCard2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      setState(() {
        currentCommentCount = widget.post.comments;
        _postInteractionProvider.isLiked = widget.post.isAlreadyLiked;
        _postInteractionProvider.likeCount = widget.post.likes;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _replyControllers.clear();
    _postInteractionProvider.dispose();
    _commentProvider.dispose();
    _replyCommentProvider.dispose();
    super.dispose();
  }

  String calculateTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Just now";
    try {
      final date = DateTime.parse(dateString).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 365) return DateFormat('MMM d, yyyy').format(date);
      if (diff.inDays > 7) return DateFormat('MMM d').format(date);
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes} min ago';
      return 'Just now';
    } catch (_) {
      return "Just now";
    }
  }

  TextEditingController _getReplyController(String commentId) {
    if (!_replyControllers.containsKey(commentId)) {
      _replyControllers[commentId] = TextEditingController();
    }
    return _replyControllers[commentId]!;
  }

  void _openReply({required String commentId, required String userName}) {
    setState(() {
      if (_activeReplyCommentId == commentId) {
        _activeReplyCommentId = null;
      } else {
        _activeReplyCommentId = commentId;
        final controller = _getReplyController(commentId);
        controller.text = "@$userName ";
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });
  }

  // int _countTotalComments(List<CommentObj> comments) {
  //   int total = 0;
  //   void countRecursively(List<CommentObj> commentList) {
  //     for (var comment in commentList) {
  //       total++;
  //       if (comment.replies.isNotEmpty) {
  //         countRecursively(comment.replies);
  //       }
  //     }
  //   }
  //   countRecursively(comments);
  //   return total;
  // }

  void _showShareBottomSheet(BuildContext context) {
    final shareTextController = TextEditingController();
    bool isAnon = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2E1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Share Shout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: shareTextController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Say something about this...",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (AppFeatureFlags.enableAnonymousPosting)
                    Row(
                      children: [
                        const Text(
                          "Share Anonymously",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const Spacer(),
                        Switch(
                          value: isAnon,
                          activeColor: const Color(0xFF00d09c),
                          onChanged: (val) => setModalState(() => isAnon = val),
                        ),
                      ],
                    ),
                  Consumer<ShareProvider>(
                    builder: (context, shareProv, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00d09c),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: shareProv.isLoading
                              ? null
                              : () async {
                            if (await shareProv.share(
                              id: widget.post.id,
                              content: shareTextController.text,
                              isAnonymous:
                                  AppFeatureFlags.enableAnonymousPosting &&
                                  isAnon,
                            )) {
                              Navigator.pop(context);
                              widget.onRefresh?.call();
                            }
                          },
                          child: shareProv.isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Share Now",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const likeColor = Color(0xFF00d09c);

    final bool hasVideo = widget.post.videoUrl != null && widget.post.videoUrl!.isNotEmpty;
    final bool hasImages = widget.post.imageUrls != null && widget.post.imageUrls!.isNotEmpty;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _postInteractionProvider),
        ChangeNotifierProvider.value(value: _commentProvider),
        ChangeNotifierProvider.value(value: _replyCommentProvider),
        ChangeNotifierProvider(create: (_) => LoadRepliedProvider()),
        ChangeNotifierProvider(create: (_) => ShareProvider()),
        ChangeNotifierProvider(create: (_) => LikeCommentProvider()),
        ChangeNotifierProvider(create: (_) => unLikedCommentProvider()),
      ],
      child: Consumer6<
          PostInteractionProvider,
          CommentProvider,
          ReplyCommentProvider,
          LoadRepliedProvider,
          LikeCommentProvider,
          unLikedCommentProvider
      >(
        builder: (providerContext, postProvider, commentProvider,
            replyProvider, loadRepliedProvider, likeCommentProv, unlikeCommentProv, _) {

          // final displayCommentCount = commentProvider.comments.isNotEmpty
          //     ? _countTotalComments(commentProvider.comments)
          //     : currentCommentCount;

          final displayCommentCount = currentCommentCount;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1F15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                if (widget.post.content.isNotEmpty) ...[
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (widget.post.originalPost != null)
                  _buildOriginalPostBox(widget.post.originalPost!),

                if (hasVideo && hasImages)
                  _buildMixedMediaGrid(widget.post.videoUrl!, widget.post.imageUrls!)
                else if (hasVideo)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: PostVideoPlayer(videoUrl: widget.post.videoUrl!),
                  )
                else if (hasImages)
                    _buildFacebookImageGrid(widget.post.imageUrls!),

                if (widget.post.voiceUrl != null)
                  VoicePlayerWidget(
                    url: widget.post.voiceUrl!,
                    duration: widget.post.voiceDuration,
                  ),

                const SizedBox(height: 12),
                _buildStats(postProvider, displayCommentCount),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF1A2E1F), height: 1),
                const SizedBox(height: 12),

                _buildActionButtons(postProvider, commentProvider, providerContext),

                if (isExpanded)
                  _buildCommentSection(
                    commentProvider,
                    likeColor,
                    providerContext,
                    likeCommentProv,
                    unlikeCommentProv,
                    loadRepliedProvider,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOriginalPostBox(Post original) {
    final bool hasVideo = original.videoUrl != null && original.videoUrl!.isNotEmpty;
    final bool hasImages = original.imageUrls != null && original.imageUrls!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (widget.onOriginalPostTap != null) {
          widget.onOriginalPostTap!(original.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xff0D1F15),
                  backgroundImage: _isValidAvatarUrl(original.userAvatar)
                      ? NetworkImage(original.userAvatar)
                      : null,
                  child: !_isValidAvatarUrl(original.userAvatar)
                      ? const Icon(Icons.person, color: Colors.white54, size: 14)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  original.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  calculateTimeAgo(original.timeAgo),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (original.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  original.content,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (hasVideo && hasImages)
              _buildMixedMediaGrid(original.videoUrl!, original.imageUrls!)
            else if (hasVideo)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PostVideoPlayer(videoUrl: original.videoUrl!, isGridMode: true),
              )
            else if (hasImages)
                _buildFacebookImageGrid(original.imageUrls!),

            if (original.voiceUrl != null)
              VoicePlayerWidget(
                url: original.voiceUrl!,
                duration: original.voiceDuration,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixedMediaGrid(String videoUrl, List<String> images) {
    int imageCount = images.length;
    void openGallery(int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imageUrls: images,
            initialIndex: index,
          ),
        ),
      );
    }
    Widget videoTile() {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0D1F15), width: 1),
        ),
        child: PostVideoPlayer(videoUrl: videoUrl, isGridMode: true),
      );
    }
    Widget imageTile(String url, int index, {bool showOverlay = false, int moreCount = 0}) {
      return GestureDetector(
        onTap: () => openGallery(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0D1F15), width: 1),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(color: const Color(0xFF1A2E1F));
                },
                errorBuilder: (ctx, error, stack) => Container(
                  color: const Color(0xFF1A2E1F),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (showOverlay)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    "+$moreCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 350,
          child: Builder(
            builder: (context) {
              if (imageCount == 1) {
                return Row(
                  children: [
                    Expanded(child: videoTile()),
                    Expanded(child: imageTile(images[0], 0)),
                  ],
                );
              }
              if (imageCount == 2) {
                return Column(
                  children: [
                    Expanded(flex: 2, child: videoTile()),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(child: imageTile(images[0], 0)),
                          Expanded(child: imageTile(images[1], 1)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              if (imageCount == 3) {
                return Column(
                  children: [
                    Expanded(flex: 2, child: videoTile()),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(child: imageTile(images[0], 0)),
                          Expanded(child: imageTile(images[1], 1)),
                          Expanded(child: imageTile(images[2], 2)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(flex: 2, child: videoTile()),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(child: imageTile(images[0], 0)),
                        Expanded(child: imageTile(images[1], 1)),
                        Expanded(
                          child: imageTile(
                              images[2],
                              2,
                              showOverlay: true,
                              moreCount: imageCount - 3
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFacebookImageGrid(List<String> images) {
    int count = images.length;
    void openGallery(int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imageUrls: images,
            initialIndex: index,
          ),
        ),
      );
    }
    Widget roundedImage(String url, int index, {bool showOverlay = false, int moreCount = 0}) {
      return GestureDetector(
        onTap: () => openGallery(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0D1F15), width: 1),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(color: const Color(0xFF1A2E1F));
                },
                errorBuilder: (ctx, error, stack) => Container(
                  color: const Color(0xFF1A2E1F),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (showOverlay)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    "+$moreCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: count == 1 ? null : 300,
          child: Builder(
            builder: (context) {
              if (count == 1) {
                return GestureDetector(
                  onTap: () => openGallery(0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: Image.network(
                      images[0],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              if (count == 2) {
                return Row(
                  children: [
                    Expanded(child: roundedImage(images[0], 0)),
                    Expanded(child: roundedImage(images[1], 1)),
                  ],
                );
              }
              if (count == 3) {
                return Column(
                  children: [
                    Expanded(flex: 2, child: roundedImage(images[0], 0)),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(child: roundedImage(images[1], 1)),
                          Expanded(child: roundedImage(images[2], 2)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              if (count == 4) {
                return Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: roundedImage(images[0], 0)),
                          Expanded(child: roundedImage(images[1], 1)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: roundedImage(images[2], 2)),
                          Expanded(child: roundedImage(images[3], 3)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: roundedImage(images[0], 0)),
                        Expanded(child: roundedImage(images[1], 1)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: roundedImage(images[2], 2)),
                        Expanded(
                          child: roundedImage(
                            images[3],
                            3,
                            showOverlay: true,
                            moreCount: count - 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentUserId = context.read<CustomAppBarProvider>().id;
    final canManagePost =
        currentUserId != null &&
        currentUserId.isNotEmpty &&
        widget.post.userId != null &&
        widget.post.userId!.isNotEmpty &&
        currentUserId == widget.post.userId;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xff0D1F15),
          backgroundImage: _getAvatarImage(),
          child: _shouldShowPlaceholder()
              ? const Icon(Icons.person, color: Colors.white54, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    widget.post.timeAgo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00d09c).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 12,
                          color: Color(0xFF00d09c),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPostTypeName(widget.post.type),
                          style: const TextStyle(
                            color: Color(0xFF00d09c),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      widget.post.location,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (canManagePost)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            color: const Color(0xFF1A2E1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShoutEditScreen(post: widget.post),
                  ),
                );
              } else if (value == 'delete') {
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed == true && mounted) {
                  final deleteProvider = context.read<ShoutPostDeleteProvider>();
                  final success = await deleteProvider.deletePost(widget.post.id);
                  if (success) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post deleted successfully'),
                        backgroundColor: Color(0xFF00d09c),
                      ),
                    );
                    final customAppBarProvider =
                        context.read<CustomAppBarProvider>();
                    final userId = customAppBarProvider.data?.id ?? '';
                    if (userId.isNotEmpty) {
                      context.read<ProfileProvider>().refreshProfile(userId);
                    }
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          deleteProvider.errorMessage ??
                              'Failed to delete post',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1F15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Post',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getPostTypeName(PostType type) {
    switch (type) {
      case PostType.Obervation: return 'Observation';
      case PostType.Concern: return 'Concern';
      case PostType.Thought: return 'Thought';
      case PostType.Gratitude: return 'Gratitude';
      case PostType.Gossip: return 'Gossip';
      default: return 'Idea';
    }
  }

  Widget _buildStats(PostInteractionProvider postProvider, int commentCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00d09c).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.thumb_up,
                size: 14,
                color: Color(0xFF00d09c),
              ),
              const SizedBox(width: 6),
              Text(
                "${postProvider.likeCount}",
                style: const TextStyle(
                  color: Color(0xFF00d09c),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          "$commentCount comments",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          "${widget.post.shares} shares",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      PostInteractionProvider postProvider,
      CommentProvider commentProvider,
      BuildContext context // Added context to open share
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionBtn(
          postProvider.isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
          "Like",
              () => postProvider.handleLikeAction(
            context,
            widget.post.id,
          ),
          isActive: postProvider.isLiked,
        ),
        _actionBtn(
          Icons.chat_bubble_outline,
          "Comment",
              () {
            setState(() => isExpanded = !isExpanded);
            if (isExpanded && commentProvider.comments.isEmpty) {
              commentProvider.fetchComments(widget.post.id);
            }
          },
          isActive: isExpanded,
        ),
        _actionBtn(Icons.share_outlined, "Share", () {
          _showShareBottomSheet(context);
        }),
      ],
    );
  }

  Widget _actionBtn(
      IconData icon,
      String label,
      VoidCallback onTap, {
        bool isActive = false,
      }) {
    final color = isActive ? const Color(0xFF00d09c) : Colors.white70;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- THE MISSING METHOD ---
  Widget _buildCommentSection(
      CommentProvider commentProvider,
      Color likeColor,
      BuildContext context,
      LikeCommentProvider likeCommentProv,
      unLikedCommentProvider unlikeCommentProv,
      LoadRepliedProvider loadRepliedProvider,
      ) {
    if (commentProvider.isLoading && commentProvider.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00d09c)),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        if (commentProvider.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "No comments yet. Be the first to comment!",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          )
        else
          ...commentProvider.comments.map((comment) {
            return _buildRecursiveCommentTree(
              comment,
              0,
              likeColor,
              context,
              likeCommentProv,
              unlikeCommentProv,
              loadRepliedProvider,
            );
          }).toList(),
        const SizedBox(height: 12),
        _buildCommentInput(context, commentProvider),
      ],
    );
  }

  Widget _buildCommentInput(
      BuildContext context,
      CommentProvider commentProvider,
      ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            cursorColor: const Color(0xFF00d09c),
            decoration: InputDecoration(
              hintText: "Add a comment...",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1A2E1F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            if (_commentController.text.trim().isEmpty) return;
            final ok = await commentProvider.postComment(
              widget.post.id,
              _commentController.text,
            );
            if (ok) {
              _commentController.clear();
              setState(() => currentCommentCount++);
              // await commentProvider.fetchComments(widget.post.id); // Not needed if postComment updates list locally
              if (mounted) FocusScope.of(context).unfocus();
            }
          },
          child: const CircleAvatar(
            backgroundColor: Color(0xFF00d09c),
            radius: 20,
            child: Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  // --- Recursive Tree with View Replies Logic ---
  Widget _buildRecursiveCommentTree(
      CommentObj comment,
      int depth,
      Color likeColor,
      BuildContext context,
      LikeCommentProvider likeCommentProv,
      unLikedCommentProvider unlikeCommentProv,
      LoadRepliedProvider loadRepliedProvider,
      ) {
    return Column(
      key: ValueKey(comment.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        depth == 0
            ? _buildSingleCommentRow(
          comment: comment,
          likeColor: likeColor,
          isReply: false,
          onReplyTap: () => _openReply(
            commentId: comment.id,
            userName: comment.userName,
          ),
          likeCommentProv: likeCommentProv,
          unlikeCommentProv: unlikeCommentProv,
        )
            : _buildReplyStructure(
          depth: depth,
          child: _buildSingleCommentRow(
            comment: comment,
            likeColor: likeColor,
            isReply: true,
            onReplyTap: () => _openReply(
              commentId: comment.id,
              userName: comment.userName,
            ),
            likeCommentProv: likeCommentProv,
            unlikeCommentProv: unlikeCommentProv,
          ),
        ),

        // --- View Replies Button Logic ---
        if (comment.repliesCount > 0 && comment.replies.isEmpty)
          Padding(
            padding: EdgeInsets.only(left: (depth + 1) * 36.0, bottom: 8),
            child: InkWell(
              onTap: () async {
                List<CommentObj> fetchedReplies = await loadRepliedProvider
                    .loadReplyComment(id: comment.id);
                if (fetchedReplies.isNotEmpty) {
                  _commentProvider.addRepliesToLocalList(
                    comment.id,
                    fetchedReplies,
                  );
                }
              },
              child: Text(
                "— View ${comment.repliesCount} replies",
                style: const TextStyle(
                  color: Color(0xFF00d09c),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        if (_activeReplyCommentId == comment.id)
          _buildReplyStructure(
            depth: depth + 1,
            child: _buildReplyInput(comment.id, context),
          ),
        if (comment.replies.isNotEmpty)
          ...comment.replies.map(
                (reply) => _buildRecursiveCommentTree(
              reply,
              depth + 1,
              likeColor,
              context,
              likeCommentProv,
              unlikeCommentProv,
              loadRepliedProvider,
            ),
          ),
      ],
    );
  }

  Widget _buildReplyInput(String parentId, BuildContext context) {
    final controller = _getReplyController(parentId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              cursorColor: const Color(0xFF00d09c),
              decoration: InputDecoration(
                hintText: "Write a reply...",
                filled: true,
                fillColor: const Color(0xFF1A2E1F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              if (controller.text.trim().isEmpty) return;
              final replyProvider = context.read<ReplyCommentProvider>();
              // Use instance of commentProvider available via read since we are inside consumer/structure
              // or use _commentProvider if accessible
              final commentProvider = context.read<CommentProvider>();

              final newReply = await replyProvider.replyComment(
                shoutId: widget.post.id,
                content: controller.text,
                parentId: parentId,
              );

              if (newReply != null) {
                // INTEGRATION: Add reply to local list
                commentProvider.addReplyToLocalList(parentId, newReply);

                controller.clear();
                if (mounted) {
                  setState(() {
                    _activeReplyCommentId = null;
                    currentCommentCount++;
                  });
                }
              }
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF00d09c),
              child: Icon(Icons.send, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED SINGLE COMMENT ROW FOR LIKES ---
  Widget _buildSingleCommentRow({
    required CommentObj comment,
    required Color likeColor,
    required bool isReply,
    required VoidCallback onReplyTap,
    required LikeCommentProvider likeCommentProv,
    required unLikedCommentProvider unlikeCommentProv,
  }) {
    // --- Like Logic Calculation ---
    final bool isLiked = _locallyLikedCommentIds.contains(comment.id) ||
        (comment.isLiked && !_locallyUnlikedCommentIds.contains(comment.id));
    final int baseLikes = _localCommentLikesCount[comment.id] ?? comment.likes;

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: const Color(0xff0D1F15),
            backgroundImage: _isValidAvatarUrl(comment.userAvatar)
                ? NetworkImage(comment.userAvatar)
                : null,
            child: !_isValidAvatarUrl(comment.userAvatar)
                ? Icon(
              Icons.person,
              color: Colors.white54,
              size: isReply ? 16 : 20,
            )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E1F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        calculateTimeAgo(comment.timeAgo),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // --- Like Button with Logic ---
                      _miniActionIcon(
                        icon: isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                        label: "$baseLikes",
                        color: isLiked ? const Color(0xFF00d09c) : Colors.grey,
                        onTap: () async {
                          if (isLiked) {
                            if (await unlikeCommentProv.unlikedComment(
                              parentId: widget.post.id,
                              childrenId: comment.id,
                            )) {
                              setState(() {
                                _locallyLikedCommentIds.remove(comment.id);
                                _locallyUnlikedCommentIds.add(comment.id);
                                _localCommentLikesCount[comment.id] = baseLikes - 1;
                              });
                            }
                          } else {
                            if (await likeCommentProv.islikedComment(
                              parentId: widget.post.id,
                              childrenId: comment.id,
                            )) {
                              setState(() {
                                _locallyLikedCommentIds.add(comment.id);
                                _locallyUnlikedCommentIds.remove(comment.id);
                                _localCommentLikesCount[comment.id] = baseLikes + 1;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      _miniActionIcon(
                        icon: Icons.chat_bubble_outline,
                        label: "Reply",
                        color: Colors.white70,
                        onTap: onReplyTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyStructure({required Widget child, required int depth}) {
    final double indent = (depth > 4 ? 4 : depth) * 16.0;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      color: const Color(0xFF1A2E1F), width: 1.5),
                  bottom: BorderSide(
                      color: const Color(0xFF1A2E1F), width: 1.5),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  bool _isValidAvatarUrl(String url) {
    return url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  ImageProvider? _getAvatarImage() {
    if (_isValidAvatarUrl(widget.post.userAvatar)) {
      return NetworkImage(widget.post.userAvatar);
    }
    return null;
  }

  bool _shouldShowPlaceholder() {
    return !_isValidAvatarUrl(widget.post.userAvatar);
  }
}

// ============================================
// FACEBOOK STYLE VIDEO PLAYER & FULL SCREEN VIEWERS
// (Kept exactly the same as PostCard2 file)
// ============================================

class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isGridMode;

  const PostVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isGridMode = false,
  });

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _showControls = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    try {
      debugPrint('VIDEO DETECTED: ${widget.videoUrl}');

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Add listener
      _controller!.addListener(_videoListener);

      await _controller!.initialize();

      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
          if (widget.isGridMode) {
            _isMuted = true;
            _controller!.setVolume(0);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Video initialization error: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_isDisposed || _controller == null || !mounted) return;

    try {
      if (_controller!.value.position >= _controller!.value.duration) {
        if (mounted && !_isDisposed) {
          setState(() {
            _showControls = true;
          });
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // CRITICAL: Remove listener FIRST
    if (_controller != null) {
      try {
        _controller!.removeListener(_videoListener);
      } catch (e) {
        debugPrint('Remove listener error: $e');
      }

      // Then pause
      try {
        _controller!.pause();
      } catch (e) {
        debugPrint('Pause error: $e');
      }

      // Finally dispose
      try {
        _controller!.dispose();
      } catch (e) {
        debugPrint('Dispose error: $e');
      }
    }

    super.dispose();
  }

  void _togglePlay() {
    if (_isDisposed || !_isInitialized || _controller == null) return;

    try {
      if (mounted) {
        setState(() {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
            _showControls = true;
          } else {
            _controller!.play();
            _showControls = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Toggle play error: $e');
    }
  }

  void _toggleMute() {
    if (_isDisposed || !_isInitialized || _controller == null) return;

    try {
      if (mounted) {
        setState(() {
          _isMuted = !_isMuted;
          _controller!.setVolume(_isMuted ? 0 : 1.0);
        });
      }
    } catch (e) {
      debugPrint('Toggle mute error: $e');
    }
  }

  void _openFullScreen() {
    if (_isDisposed || !_isInitialized || _controller == null) return;

    try {
      _controller!.pause();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(videoUrl: widget.videoUrl),
        ),
      );
    } catch (e) {
      debugPrint('Open fullscreen error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        height: widget.isGridMode ? double.infinity : 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00d09c)),
        ),
      );
    }

    Widget playerContent = Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (mounted && !_isDisposed) {
              setState(() {
                _showControls = !_showControls;
              });
            }
          },
          child: SizedBox.expand(
            child: FittedBox(
              fit: widget.isGridMode ? BoxFit.cover : BoxFit.contain,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
        if (_showControls || !_controller!.value.isPlaying)
          Container(
            color: Colors.black26,
            child: Center(
              child: IconButton(
                iconSize: widget.isGridMode ? 30 : 50,
                icon: Icon(
                  _controller!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: const Color(0xFF00d09c),
                ),
                onPressed: _togglePlay,
              ),
            ),
          ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Row(
            children: [
              GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: widget.isGridMode ? 16 : 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openFullScreen,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: widget.isGridMode ? 16 : 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showControls && !widget.isGridMode)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color(0xFF00d09c),
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
      ],
    );

    if (widget.isGridMode) {
      return Container(
        color: Colors.black,
        child: playerContent,
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: playerContent,
          ),
        ),
      );
    }
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00d09c),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${widget.imageUrls.length}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _controller!.initialize();

      if (!_isDisposed && mounted) {
        setState(() => _isInitialized = true);
        _controller!.play();
        _controller!.setLooping(true);
      }
    } catch (e) {
      debugPrint('❌ Fullscreen video error: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    if (_controller != null) {
      try {
        _controller!.pause();
        _controller!.dispose();
      } catch (e) {
        debugPrint('Dispose error: $e');
      }
    }

    super.dispose();
  }

  void _togglePlayPause() {
    if (_isDisposed || !_isInitialized || _controller == null) return;

    try {
      if (mounted) {
        setState(() {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        });
      }
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: !_isInitialized || _controller == null
              ? const CircularProgressIndicator(color: Color(0xFF00d09c))
              : AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (mounted && !_isDisposed) {
                      setState(() => _showControls = !_showControls);
                    }
                  },
                  child: VideoPlayer(_controller!),
                ),
                if (_showControls)
                  Container(
                    color: Colors.black26,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          left: 20,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              if (!_isDisposed && _controller != null) {
                                try {
                                  _controller!.pause();
                                } catch (e) {
                                  debugPrint('Pause error: $e');
                                }
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Center(
                          child: IconButton(
                            iconSize: 60,
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: const Color(0xFF00d09c),
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Color(0xFF00d09c),
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
