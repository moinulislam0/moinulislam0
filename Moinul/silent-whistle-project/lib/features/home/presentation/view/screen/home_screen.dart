import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:jwells/features/auth/model/shoutModel.dart';
import 'package:jwells/features/auth/model_view/shout_provider.dart';
import 'package:jwells/features/home/presentation/view/widgets/postCard.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_ber.dart';
import 'package:jwells/features/profile/presentation/view/screens/setting_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _postKeys = {};


  final List<String> categories = ['All', 'Observation', 'Concern', 'Thought', 'Gratitude', 'Gossip', 'Idea'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomAppBarProvider>().fetchAppBar();
      context.read<ShoutProvider>().fetchAllShouts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        context.read<ShoutProvider>().fetchMoreShouts();
      }
    });
  }

  PostType getPostTypeFromString(String? category) {
    String cat = (category ?? "Idea").toLowerCase().trim();
    if (cat == 'observation') return PostType.Obervation;
    if (cat == 'concern') return PostType.Concern;
    if (cat == 'thought') return PostType.Thought;
    if (cat == 'gratitude') return PostType.Gratitude;
    if (cat == 'gossip') return PostType.Gossip;
    return PostType.Idea;
  }

  String calculateTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Just now";
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      final Duration diff = DateTime.now().difference(date);
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return "Just now";
    }
  }

 Post _mapShoutToPost(ShoutModel item) {
  List<String> postImageUrls = [];
  String? voiceUrl, voiceDuration, videoUrl;

  if (item.medias != null) {
    for (var m in item.medias!) {
      final String url = m.url ?? "";
      final String type = (m.type ?? "").toLowerCase();
      final String urlLower = url.toLowerCase();

      if (type.contains("video") || 
          urlLower.endsWith(".mp4") || 
          urlLower.endsWith(".mov") || 
          urlLower.endsWith(".avi")) {
        videoUrl = url;
        print("VIDEO DETECTED: $url");
      } 

      else if (type.contains("audio") || 
               type.contains("voice") || 
               urlLower.endsWith(".m4a") || 
               urlLower.endsWith(".mp3")) {
        voiceUrl = url;
        voiceDuration = m.duration;
      } 

      else if (url.isNotEmpty) {
        postImageUrls.add(url);
      }
    }
  }

    final shouldMaskIdentity =
        AppFeatureFlags.shouldMaskIdentity(item.isAnonymous ?? false);

    return Post(
    id: item.id ?? "",
    userName: shouldMaskIdentity ? "Anonymous" : (item.user?.name ?? "Unknown"),
    userAvatar: shouldMaskIdentity ? "" : (item.user?.avatar ?? ""),
    userId: item.user?.id,
    isAnonymous: shouldMaskIdentity,
    timeAgo: calculateTimeAgo(item.createdAt),
    location: item.location ?? "Unknown Location",
    category: item.category ?? "Idea",
    type: getPostTypeFromString(item.category),
    content: item.content ?? "",
    imageUrls: postImageUrls,
    voiceUrl: voiceUrl,
    videoUrl: videoUrl,
    voiceDuration: voiceDuration,
    likes: item.likesCount ?? 0,
    comments: item.commentsCount ?? 0,
    shares: item.sharesCount ?? 0,
    isAlreadyLiked: item.isLiked ?? false,
    originalPost: item.originalShout != null ? _mapShoutToPost(item.originalShout!) : null,
  );
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: -20,
      ),
      extendBodyBehindAppBar: false,
      backgroundColor: const Color(0xff010702),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Consumer<CustomAppBarProvider>(
              builder: (context, csProvider, child) => CustomContainer(
                userName: csProvider.name,
                ontap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  SettingScreen())),
              ),
            ),
            _buildCategoryFilter(),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<ShoutProvider>(
                builder: (context, provider, child) {
        
                  if (provider.isLoading && provider.shoutsList.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF38E07B)));
                  }
        
        
                  final filteredShouts = selectedIndex == 0
                      ? provider.shoutsList
                      : provider.shoutsList.where((shout) {
                          String shoutCat = (shout.category ?? "Idea").toLowerCase().trim();
                          String selectedCat = categories[selectedIndex].toLowerCase().trim();
                          return shoutCat == selectedCat;
                        }).toList();
                  final Set<String> attachedKeyIds = <String>{};
        
                  if (filteredShouts.isEmpty && !provider.isLoading) {
                    return const Center(child: Text("No posts found in this category", style: TextStyle(color: Colors.white)));
                  }
        
                  return RefreshIndicator(
                    onRefresh: () async => await provider.fetchAllShouts(isRefresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredShouts.length + (provider.isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredShouts.length) {
                          return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Color(0xFF38E07B))));
                        }
        
                        final item = filteredShouts[index];
                        final itemId = item.id;
                        final shouldAttachGlobalKey =
                            itemId != null &&
                            itemId.isNotEmpty &&
                            attachedKeyIds.add(itemId);
                        final GlobalKey? postKey = shouldAttachGlobalKey
                            ? _postKeys.putIfAbsent(itemId, () => GlobalKey())
                            : null;

                        return Container(
                          key: postKey,
                          child: PostCard(
                            key: ValueKey('${item.id ?? 'post'}_$index'),
                            post: _mapShoutToPost(item),
                            onRefresh: () => provider.fetchAllShouts(isRefresh: true),
                            onOriginalPostTap: (originalPostId) {
                              final targetKey = _postKeys[originalPostId];
                              if (targetKey != null && targetKey.currentContext != null) {
                                Scrollable.ensureVisible(targetKey.currentContext!,
                                    duration: const Duration(milliseconds: 600), curve: Curves.easeInOut, alignment: 0.5);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
           
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF38E07B) : const Color(0xFF031406),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 20,vertical: 2),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
