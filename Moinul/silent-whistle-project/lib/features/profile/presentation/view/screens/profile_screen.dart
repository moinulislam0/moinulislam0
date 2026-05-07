import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:jwells/features/payment/presentation/view/screens/select_subscription_plan_screen.dart';
import 'package:jwells/core/services/local_storage_service/location_storage.dart';
import 'package:jwells/features/profile/data/model/profile_response_model.dart';
import 'package:jwells/features/profile/presentation/viewmodel/profile_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/report_user_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:provider/provider.dart';

import '../../../../home/presentation/viewmodel/post_model.dart';
import '../../../../parent/model_view/parent_screen_provider.dart';
import '../widgets/post_card2.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final LocationStorage _locationStorage = LocationStorage();
  String? _savedLocationText;

  @override
  void initState() {
    super.initState();
    _initialData();
    _scrollController.addListener(_onScroll);
    _loadSavedLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomAppBarProvider>().fetchAppBar();
      context.read<ProfileProvider>().getProfile(widget.userId, refresh: true);
    });
  }

  Future<void> _loadSavedLocation() async {
    final savedLocation = await _locationStorage.getLocationText();
    if (!mounted) return;
    setState(() {
      _savedLocationText = savedLocation;
    });
  }

  bool _isOwnProfile(String? currentUserId) {
    return currentUserId != null &&
        currentUserId.isNotEmpty &&
        currentUserId == widget.userId;
  }

  Future<void> _reportUser() async {
    final success = await context.read<ReportUserProvider>().reportUser(
      widget.userId,
    );
    if (!mounted) return;

    final provider = context.read<ReportUserProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (provider.successMessage ?? 'User reported successfully.')
              : (provider.errorMessage ?? 'Failed to report user.'),
        ),
        backgroundColor:
            success ? const Color(0xff00d09c) : Colors.redAccent,
      ),
    );
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    context.read<ParentScreenProvider>().setIndex(0);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final profileProvider = context.read<ProfileProvider>();
      if (!profileProvider.isLoadingMore && profileProvider.hasMoreData) {
        profileProvider.loadMorePosts(widget.userId);
      }
    }
  }

  String calculateTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Just now";
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      final Duration diff = DateTime.now().difference(date);

      if (diff.inDays > 365) {
        return DateFormat('MMM d, yyyy').format(date);
      } else if (diff.inDays > 7) {
        return DateFormat('MMM d').format(date);
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return "Just now";
    }
  }

  PostType getPostTypeFromString(String? category) {
    if (category == null) return PostType.Idea;
    switch (category.toLowerCase()) {
      case 'observation':
        return PostType.Obervation;
      case 'concern':
        return PostType.Concern;
      case 'thought':
        return PostType.Thought;
      case 'gratitude':
        return PostType.Gratitude;
      case 'gossip':
        return PostType.Gossip;
      default:
        return PostType.Idea;
    }
  }


  Post _mapShoutToPost(dynamic item, CustomAppBarProvider csProvider) {
    List<String> postImageUrls = [];
    String? voiceUrl, voiceDuration, videoUrl;

    // Process medias
    if (item.medias != null && item.medias!.isNotEmpty) {
      for (var m in item.medias!) {
        final String url = m.url ?? "";
        if (url.isEmpty) continue;

        final String type = (m.type ?? "").toLowerCase();
        final String urlLower = url.toLowerCase();

        bool isVideo = type.contains("video") ||
            urlLower.endsWith(".mp4") ||
            urlLower.endsWith(".mov") ||
            urlLower.endsWith(".avi");

        bool isAudio = type.contains("audio") ||
            type.contains("voice") ||
            urlLower.endsWith(".m4a") ||
            urlLower.endsWith(".mp3") ||
            urlLower.endsWith(".wav");

        bool isImage = type.contains("image") ||
            urlLower.endsWith(".jpg") ||
            urlLower.endsWith(".jpeg") ||
            urlLower.endsWith(".png") ||
            urlLower.endsWith(".gif");

        if (isVideo && videoUrl == null) {
          videoUrl = url;
        } else if (isImage && !isVideo && !isAudio) {
          postImageUrls.add(url);
        } else if (isAudio && voiceUrl == null) {
          voiceUrl = url;
          voiceDuration = m.duration;
        }
      }
    }

    final bool isAnon =
        AppFeatureFlags.shouldMaskIdentity(item.isAnonymous ?? false);



    return Post(
      id: item.id ?? "",
      userName: isAnon
          ? "Anonymous"
          : (item.user?.name ?? csProvider.name ?? "Unknown"),
      userAvatar: isAnon
          ? ""
          : (item.user?.avatar ?? csProvider.avatar ?? ""),
      userId: item.user?.id,
      isAnonymous: isAnon,
      timeAgo: calculateTimeAgo(item.createdAt),
      location: item.location ?? "Unknown Location",
      category: item.category ?? "Idea",
      type: getPostTypeFromString(item.category),
      content: item.content ?? "",
      imageUrls: postImageUrls.isNotEmpty ? postImageUrls : null,
      voiceUrl: voiceUrl,
      videoUrl: videoUrl,
      voiceDuration: voiceDuration,
      likes: item.likesCount?.toInt() ?? 0,
      comments: item.commentsCount?.toInt() ?? 0,
      shares: item.sharesCount?.toInt() ?? 0,
      isAlreadyLiked: item.isLiked ?? false,
     
      originalPost: item.originalShout != null
          ? _mapShoutToPost(item.originalShout!, csProvider)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Consumer2<CustomAppBarProvider, ProfileProvider>(
          builder: (context, csProvider, profileProvider, child) {
            final viewedProfile = profileProvider.profile;
            final isOwnProfile = _isOwnProfile(csProvider.id);

            if (profileProvider.isLoading &&
                profileProvider.profile == null &&
                profileProvider.posts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff00d09c),
                ),
              );
            }

            final profile = profileProvider.profile;
            final posts = profileProvider.posts;

            return RefreshIndicator(
              onRefresh: () async {
                await csProvider.fetchAppBar();
                await profileProvider.refreshProfile(widget.userId);
              },
              color: const Color(0xff00d09c),
              backgroundColor: const Color(0xff010702),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _handleBack,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xff0D1F15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          isOwnProfile
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.settingScreen,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xff0D1F15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.settings_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xff0D1F15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: PopupMenuButton<String>(
                                    color: const Color(0xff0D1F15),
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'report') {
                                        _reportUser();
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem<String>(
                                        value: 'report',
                                        child: Text(
                                          'Report User',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  if (viewedProfile != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            SizedBox(height: 8.h),
                            _buildProfileHeader(viewedProfile, isOwnProfile),
                            SizedBox(height: 24.h),
                            _buildAboutSection(viewedProfile),
                            SizedBox(height: 24.h),
                            Divider(
                              color: Colors.white.withValues(alpha: 0.1),
                              thickness: 1,
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                    ),

                  if (profileProvider.requiresSubscription)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline,
                                  color: Colors.red.shade300, size: 50.w),
                              SizedBox(height: 16.h),
                              Text(
                                profileProvider.errorMessage ??
                                    'Subscription required to view this profile',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.sp),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentMethodScreen(
                                        onPurchaseSuccess: () async {
                                          Navigator.of(context).pop();
                                          await profileProvider
                                              .refreshProfile(widget.userId);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Subscription refreshed'),
                                                backgroundColor:
                                                    Color(0xff00d09c),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff00d09c),
                                ),
                                child: const Text('Go to Subscription'),
                              ),
                              SizedBox(height: 12.h),
                              TextButton(
                                onPressed: () => profileProvider.refreshProfile(
                                    widget.userId),
                                child: const Text('Retry later'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (profileProvider.errorMessage != null &&
                      profile == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline,
                                  color: Colors.red.shade300, size: 50.w),
                              SizedBox(height: 16.h),
                              Text(
                                profileProvider.errorMessage!,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.sp),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () =>
                                    profileProvider.refreshProfile(widget.userId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff00d09c),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (profile != null) ...[
                    if (posts.isEmpty && !profileProvider.isLoading)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 60.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.post_add_outlined,
                                  size: 64,
                                  color: Colors.grey.shade700,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  isOwnProfile
                                      ? 'Your posts will appear here'
                                      : 'This user has not posted anything yet',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final item = posts[index];

                              // ✅ USE THE NEW MAPPING FUNCTION
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: PostCard2(
                                  key: ValueKey(item.id ?? index.toString()),
                                  post: _mapShoutToPost(item, csProvider),
                                ),
                              );
                            },
                            childCount: posts.length,
                          ),
                        ),
                      ),
                  ],

                  if (profileProvider.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff00d09c),
                          ),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: 20.h),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildLocationText(dynamic data) {
    if (data == null) return _savedLocationText ?? "Location not set";

    List<String> parts = [];
    try {
      var city = (data is Map) ? data['city'] : data.city;
      var country = (data is Map) ? data['country'] : data.country;
      var address = (data is Map) ? data['address'] : data.address;

      if (city != null && city.toString().trim().isNotEmpty) {
        parts.add(city.toString().trim());
      }
      if (country != null && country.toString().trim().isNotEmpty) {
        parts.add(country.toString().trim());
      }

      if (parts.isEmpty && address != null && address.toString().trim().isNotEmpty) {
        return address.toString().trim();
      }
    } catch (e) {
      try {
        if (data.address != null) return data.address;
      } catch (e) {}
      return _savedLocationText ?? "Location not set";
    }

    return parts.isEmpty
        ? (_savedLocationText ?? "Location not set")
        : parts.join(", ");
  }

  Widget _buildProfileHeader(Profile profile, bool isOwnProfile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xff00d09c),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: profile.avatar != null && profile.avatar!.isNotEmpty
                ? Image.network(
              profile.avatar!,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 80,
                  width: 80,
                  color: const Color(0xff0D1F15),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xff00d09c),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: 80,
                  color: const Color(0xff0D1F15),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white54,
                  ),
                );
              },
            )
                : Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xff0D1F15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                  child: Text(
                      profile.name ?? "N/A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isOwnProfile)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteNames.editProfileScreen,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Color(0xff00d09c),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "@${profile.username ?? "silentwhistle-user"}",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xff00d09c),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _buildLocationText(profile),
                      style: const TextStyle(
                        color: Color(0xff00d09c),
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(dynamic data) {
    String nameText = "N/A";
    String aboutText = 'No bio added yet.';

    if (data != null) {
      if (data is Map) {
        nameText = data['name'] ?? nameText;
        aboutText = data['about'] ?? aboutText;
      } else {
        try {
          nameText = data.name ?? nameText;
        } catch (e) {}
        try {
          if (data.about != null) aboutText = data.about;
        } catch (e) {}
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'About',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                nameText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            aboutText,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
