import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:jwells/features/home/presentation/provider_model/comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/post_interaction_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/report_post_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/reply_comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/load_reply_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/share_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/like_comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/unlike_comment_provider.dart';
import 'package:jwells/features/home/presentation/view/widgets/voice_player_widget.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';
import 'package:jwells/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:jwells/features/profile/presentation/viewmodel/block_user_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onRefresh;
  final Function(String postId)? onOriginalPostTap;

  const PostCard({
    super.key,
    required this.post,
    this.onRefresh,
    this.onOriginalPostTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  String? _activeReplyCommentId;
  late int currentCommentCount;

  final Set<String> _locallyLikedCommentIds = {};
  final Set<String> _locallyUnlikedCommentIds = {};
  final Map<String, int> _localCommentLikesCount = {};

  late PostInteractionProvider _postInteractionProvider;
  late CommentProvider _commentProvider;
  late ReplyCommentProvider _replyCommentProvider;
  late ReportPostProvider _reportPostProvider;

  String get targetId => widget.post.id;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    currentCommentCount = widget.post.comments;
    _postInteractionProvider = PostInteractionProvider(
      isLiked: widget.post.isAlreadyLiked,
      likeCount: widget.post.likes,
    );
    _commentProvider = CommentProvider();
    _replyCommentProvider = ReplyCommentProvider();
    _reportPostProvider = ReportPostProvider();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      setState(() {
        currentCommentCount = widget.post.comments;
        _postInteractionProvider.isLiked = widget.post.isAlreadyLiked;
        _postInteractionProvider.likeCount = widget.post.likes;
      });
    }
  }

  String _convertToTimeAgo(String time) {
    try {
      DateTime postDate = DateTime.parse(time);
      Duration diff = DateTime.now().difference(postDate);
      if (diff.inSeconds < 60) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 30) return "${diff.inDays}d ago";
      return "${(diff.inDays / 30).floor()}mo ago";
    } catch (e) {
      return time;
    }
  }

  void _toggleComments() {
    setState(() => isExpanded = !isExpanded);
    if (isExpanded && _commentProvider.comments.isEmpty) {
      _commentProvider.fetchComments(targetId);
    }
  }

  Widget _customNetworkImage(
    String url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    if (url.isEmpty) return _buildErrorPlaceholder();
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: Colors.white.withOpacity(0.05),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.05),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 30,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.forEach((key, controller) => controller.dispose());
    _reportPostProvider.dispose();
    super.dispose();
  }

  Future<void> _reportPost() async {
    final success = await _reportPostProvider.reportPost(widget.post.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _reportPostProvider.successMessage ??
                'Post reported successfully.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _reportPostProvider.errorMessage ?? 'Failed to report post.',
        ),
      ),
    );
  }

  Future<void> _blockUser() async {
    final targetUserId = widget.post.userId;
    if (targetUserId == null || targetUserId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This anonymous post cannot be blocked right now.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = context.read<BlockUserProvider>();
    final success = await provider.blockUser(targetUserId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (provider.successMessage ?? 'User blocked successfully.')
              : (provider.errorMessage ?? 'Failed to block user.'),
        ),
        backgroundColor:
            success ? const Color(0xFF38E07B) : Colors.redAccent,
      ),
    );

    if (success) {
      widget.onRefresh?.call();
    }
  }

  void _openUserProfile() {
    final targetUserId = widget.post.userId;
    final currentUserId = context.read<CustomAppBarProvider>().id;

    if (widget.post.isAnonymous ||
        targetUserId == null ||
        targetUserId.isEmpty ||
        targetUserId == currentUserId) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: targetUserId),
      ),
    );
  }

  void _openGallery(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PostImageGallery(imageUrls: images, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    int count = images.length;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = 300;

          if (count == 1) {
            return GestureDetector(
              onTap: () => _openGallery(context, images, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _customNetworkImage(
                  images[0],
                  width: width,
                  height: 250,
                ),
              ),
            );
          } else if (count == 2) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openGallery(context, images, 0),
                        child: _customNetworkImage(images[0]),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openGallery(context, images, 1),
                        child: _customNetworkImage(images[1]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (count == 3) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 250,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openGallery(context, images, 0),
                        child: _customNetworkImage(images[0]),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openGallery(context, images, 1),
                              child: _customNetworkImage(images[1]),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openGallery(context, images, 2),
                              child: _customNetworkImage(images[2]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: height,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openGallery(context, images, 0),
                              child: _customNetworkImage(images[0]),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openGallery(context, images, 1),
                              child: _customNetworkImage(images[1]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openGallery(context, images, 2),
                              child: _customNetworkImage(images[2]),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openGallery(context, images, 3),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _customNetworkImage(images[3]),
                                  if (count > 4)
                                    Container(
                                      color: Colors.black.withOpacity(0.6),
                                      child: Center(
                                        child: Text(
                                          "+${count - 3}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMixedMediaGrid(String videoUrl, List<String> images) {
    int imageCount = images.length;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          PostVideoPlayer(videoUrl: videoUrl, isGridMode: true),
          const SizedBox(height: 2),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGallery(context, images, 0),
                    child: _customNetworkImage(images[0]),
                  ),
                ),
                if (imageCount > 1) const SizedBox(width: 2),
                if (imageCount > 1)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openGallery(context, images, 1),
                      child: _customNetworkImage(images[1]),
                    ),
                  ),
                if (imageCount > 2) const SizedBox(width: 2),
                if (imageCount > 2)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openGallery(context, images, 2),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _customNetworkImage(images[2]),
                          if (imageCount > 3)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  "+${imageCount - 2}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(Post postData) {
    final bool hasVideo =
        postData.videoUrl != null && postData.videoUrl!.isNotEmpty;
    final bool hasImages =
        postData.imageUrls != null && postData.imageUrls!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImages && hasVideo)
          _buildMixedMediaGrid(postData.videoUrl!, postData.imageUrls!)
        else if (hasVideo)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: PostVideoPlayer(videoUrl: postData.videoUrl!),
          )
        else if (hasImages)
          _buildImageGrid(postData.imageUrls!),

        if (postData.voiceUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: VoicePlayerWidget(
              url: postData.voiceUrl!,
              duration: postData.voiceDuration,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _postInteractionProvider),
        ChangeNotifierProvider.value(value: _commentProvider),
        ChangeNotifierProvider.value(value: _replyCommentProvider),
        ChangeNotifierProvider.value(value: _reportPostProvider),
        ChangeNotifierProvider(create: (_) => LoadRepliedProvider()),
        ChangeNotifierProvider(create: (_) => ShareProvider()),
        ChangeNotifierProvider(create: (_) => LikeCommentProvider()),
        ChangeNotifierProvider(create: (_) => unLikedCommentProvider()),
      ],
      child:
          Consumer6<
            PostInteractionProvider,
            CommentProvider,
            ReplyCommentProvider,
            LoadRepliedProvider,
            LikeCommentProvider,
            unLikedCommentProvider
          >(
            builder:
                (
                  context,
                  postProvider,
                  commentProvider,
                  replyProvider,
                  loadRepliedProvider,
                  likeCommentProv,
                  unlikeCommentProv,
                  _,
                ) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(widget.post),
                        const SizedBox(height: 12),
                        if (widget.post.content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              widget.post.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        if (widget.post.originalPost != null)
                          _buildOriginalPostBox(widget.post.originalPost!),
                        _buildMediaSection(widget.post),
                        const SizedBox(height: 16),
                        _buildStats(
                          postProvider,
                          currentCommentCount,
                          widget.post.shares,
                        ),
                        const Divider(color: Colors.white10, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _actionBtn(
                              postProvider.isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_off_alt,
                              "Like",
                              () => postProvider.handleLikeAction(
                                context,
                                targetId,
                              ),
                              isActive: postProvider.isLiked,
                            ),
                            _actionBtn(
                              Icons.chat_bubble_outline,
                              "Comment",
                              _toggleComments,
                              isActive: isExpanded,
                            ),
                            _actionBtn(
                              Icons.share_outlined,
                              "Share",
                              () => _showShareBottomSheet(context),
                            ),
                          ],
                        ),
                        if (isExpanded)
                          _buildCommentSection(
                            commentProvider,
                            const Color(0xFF38E07B),
                            context,
                            likeCommentProv,
                            unlikeCommentProv,
                          ),
                      ],
                    ),
                  );
                },
          ),
    );
  }

  Widget _buildHeader(Post post) {
    final currentUserId = context.read<CustomAppBarProvider>().id;
    final isOwnPost =
        currentUserId != null &&
        currentUserId.isNotEmpty &&
        post.userId != null &&
        post.userId!.isNotEmpty &&
        post.userId == currentUserId;
    final canOpenProfile =
        !post.isAnonymous &&
        post.userId != null &&
        post.userId!.isNotEmpty &&
        !isOwnPost;
    final canBlockUser =
        post.userId != null &&
        post.userId!.isNotEmpty &&
        !isOwnPost;
    final canReportPost = !isOwnPost;

    return Row(
      children: [
        GestureDetector(
          onTap: canOpenProfile ? _openUserProfile : null,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white10,
            child: ClipOval(
              child: _customNetworkImage(post.userAvatar, width: 40, height: 40),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: canOpenProfile ? _openUserProfile : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38E07B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.type.name.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF38E07B),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        post.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Text(
          post.timeAgo,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        if (canReportPost || canBlockUser)
          PopupMenuButton<String>(
            color: const Color(0xFF1E1E1E),
            icon: const Icon(Icons.more_horiz, color: Colors.white70),
            onSelected: (value) {
              if (value == 'report') {
                _reportPost();
              } else if (value == 'block') {
                _blockUser();
              }
            },
            itemBuilder: (context) => [
              if (canReportPost)
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Text(
                    'Report',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (canBlockUser)
                PopupMenuItem<String>(
                  value: 'block',
                  child: Text(
                    post.isAnonymous
                        ? 'Block Anonymous User'
                        : 'Block User',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildStats(
    PostInteractionProvider postProvider,
    int commentCount,
    int shares,
  ) {
    return Row(
      children: [
        const Icon(Icons.thumb_up, size: 16, color: Color(0xFF38E07B)),
        const SizedBox(width: 6),
        Text(
          "${postProvider.likeCount}",
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleComments,
          child: Text(
            "$commentCount comments • $shares shares",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    final color = isActive ? const Color(0xFF38E07B) : Colors.white70;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(
    CommentProvider commentProvider,
    Color likeColor,
    BuildContext context,
    LikeCommentProvider likeCommentProv,
    unLikedCommentProvider unlikeCommentProv,
  ) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (commentProvider.isLoading && commentProvider.comments.isEmpty)
          const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF38E07B),
              ),
            ),
          )
        else
          ...commentProvider.comments.map(
            (comment) => _buildRecursiveCommentTree(
              comment,
              0,
              likeColor,
              context,
              likeCommentProv,
              unlikeCommentProv,
            ),
          ),
        _buildCommentInput(context, commentProvider),
      ],
    );
  }

  Widget _buildRecursiveCommentTree(
    CommentObj comment,
    int depth,
    Color likeColor,
    BuildContext context,
    LikeCommentProvider likeCommentProv,
    unLikedCommentProvider unlikeCommentProv,
  ) {
    final loadRepliedProvider = Provider.of<LoadRepliedProvider>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (depth > 0)
              Container(
                width: 24,
                height: 40,
                margin: EdgeInsets.only(left: (depth - 1) * 32.0 + 16),
                child: CustomPaint(painter: LShapePainter()),
              ),
            Expanded(
              child: _buildSingleCommentRow(
                comment: comment,
                likeColor: likeColor,
                isReply: depth > 0,
                onReplyTap: () => _openReply(
                  commentId: comment.id,
                  userName: comment.userName,
                ),
                likeCommentProv: likeCommentProv,
                unlikeCommentProv: unlikeCommentProv,
              ),
            ),
          ],
        ),
        if (comment.repliesCount > 0 && comment.replies.isEmpty)
          Padding(
            padding: EdgeInsets.only(left: (depth + 1) * 36.0, bottom: 8),
            child: InkWell(
              onTap: () async {
                List<CommentObj> fetchedReplies = await loadRepliedProvider
                    .loadReplyComment(id: comment.id);
                if (fetchedReplies.isNotEmpty)
                  _commentProvider.addRepliesToLocalList(
                    comment.id,
                    fetchedReplies,
                  );
              },
              child: Text(
                "— View ${comment.repliesCount} replies",
                style: const TextStyle(
                  color: Color(0xFF38E07B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (_activeReplyCommentId == comment.id)
          Padding(
            padding: EdgeInsets.only(left: (depth + 1) * 32.0, bottom: 10),
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
            ),
          ),
      ],
    );
  }

  Widget _buildSingleCommentRow({
    required CommentObj comment,
    required Color likeColor,
    required bool isReply,
    required VoidCallback onReplyTap,
    required LikeCommentProvider likeCommentProv,
    required unLikedCommentProvider unlikeCommentProv,
  }) {
    final bool isLiked =
        _locallyLikedCommentIds.contains(comment.id) ||
        (comment.isLiked && !_locallyUnlikedCommentIds.contains(comment.id));
    final int baseLikes = _localCommentLikesCount[comment.id] ?? comment.likes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 14 : 17,
              backgroundColor: Colors.white10,
              child: ClipOval(
                child: _customNetworkImage(
                  comment.userAvatar,
                  width: isReply ? 28 : 34,
                  height: isReply ? 28 : 34,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _convertToTimeAgo(comment.timeAgo),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: isReply ? 38 : 45, top: 4, bottom: 8),
          child: Row(
            children: [
              _miniActionIcon(
                icon: isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                label: "$baseLikes",
                color: isLiked ? const Color(0xFF38E07B) : Colors.grey,
                onTap: () async {
                  if (isLiked) {
                    if (await unlikeCommentProv.unlikedComment(
                      parentId: targetId,
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
                      parentId: targetId,
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
                label: "${comment.repliesCount}",
                color: Colors.grey,
                onTap: onReplyTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    CommentProvider commentProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF38E07B)),
            onPressed: () async {
              if (_commentController.text.trim().isEmpty) return;
              if (await commentProvider.postComment(
                targetId,
                _commentController.text,
              )) {
                _commentController.clear();
                setState(() => currentCommentCount++);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput(String parentId, BuildContext context) {
    final controller = _getReplyController(parentId);
    final replyProvider = Provider.of<ReplyCommentProvider>(
      context,
      listen: false,
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: "Reply...",
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Color(0xFF38E07B), size: 20),
          onPressed: () async {
            if (controller.text.trim().isEmpty) return;
            final newReply = await replyProvider.replyComment(
              shoutId: targetId,
              content: controller.text,
              parentId: parentId,
            );
            if (newReply != null) {
              _commentProvider.addReplyToLocalList(parentId, newReply);
              controller.clear();
              setState(() {
                currentCommentCount++;
                _activeReplyCommentId = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildOriginalPostBox(Post original) {
    return GestureDetector(
      onTap: () => widget.onOriginalPostTap?.call(original.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white10,
                  child: ClipOval(
                    child: _customNetworkImage(
                      original.userAvatar,
                      width: 24,
                      height: 24,
                    ),
                  ),
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
                  original.timeAgo,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (original.content.isNotEmpty)
              Text(
                original.content,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            _buildMediaSection(original),
          ],
        ),
      ),
    );
  }

  Widget _miniActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  TextEditingController _getReplyController(String commentId) =>
      _replyControllers.putIfAbsent(commentId, () => TextEditingController());
  void _openReply({required String commentId, required String userName}) {
    setState(() {
      if (_activeReplyCommentId == commentId) {
        _activeReplyCommentId = null;
      } else {
        _activeReplyCommentId = commentId;
        _getReplyController(commentId).text = "@$userName ";
      }
    });
  }

  void _showShareBottomSheet(BuildContext context) {
    final shareTextController = TextEditingController();
    bool isAnon = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
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
                          activeColor: const Color(0xFF38E07B),
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
                            backgroundColor: const Color(0xFF38E07B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: shareProv.isLoading
                              ? null
                              : () async {
                                  if (await shareProv.share(
                                    id: targetId,
                                    content: shareTextController.text,
                                    isAnonymous: AppFeatureFlags
                                        .enableAnonymousPosting &&
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
}

class PostImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const PostImageGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });
  @override
  State<PostImageGallery> createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<PostImageGallery> {
  late PageController _pageController;
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${_currentIndex + 1} / ${widget.imageUrls.length}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF38E07B),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Video Player ---

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
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            if (widget.isGridMode) {
              _isMuted = true;
              _controller.setVolume(0);
              _controller.play();
              _controller.setLooping(true);
              _showControls = false;
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF38E07B),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.isGridMode ? 0 : 12),
      child: Container(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                child: VideoPlayer(_controller),
              ),
              if (_showControls || !_controller.value.isPlaying)
                IconButton(
                  iconSize: 50,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: const Color(0xFF38E07B),
                  ),
                  onPressed: () => setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  }),
                ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _isMuted = !_isMuted;
                        _controller.setVolume(_isMuted ? 0 : 1.0);
                      }),
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _controller.pause();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenVideoPlayer(
                              videoUrl: widget.videoUrl,
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: !_isInitialized
              ? const CircularProgressIndicator(color: Color(0xFF38E07B))
              : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showControls = !_showControls),
                        child: VideoPlayer(_controller),
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
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Center(
                                child: IconButton(
                                  iconSize: 60,
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: const Color(0xFF38E07B),
                                  ),
                                  onPressed: () => setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  }),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: Color(0xFF38E07B),
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

class LShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width / 2, -20);
    path.lineTo(size.width / 2, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
