import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jwells/features/alerts/data/model/notify_model.dart';
import 'package:jwells/features/alerts/screen/view/post_details_screen.dart';
import 'package:jwells/features/alerts/screen/viewmodel/alert_delete_provider.dart';
import 'package:jwells/features/alerts/screen/viewmodel/alert_provider.dart';
import 'package:jwells/features/parent/model_view/parent_screen_provider.dart';
import 'package:jwells/features/profile/presentation/view/screens/setting_screen.dart';
import 'package:provider/provider.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  int selectedTab = 0;
  final List<String> tabs = ["All", "Concerns", "Idea", "Gossip"];

  String? openedNotificationId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AlertProvider>().fetchNotifications());
  }

  void closeOpenedTile() {
    if (openedNotificationId != null) {
      setState(() {
        openedNotificationId = null;
      });
    }
  }

  List<NotificationModel> getFilteredList(List<NotificationModel> allNoti) {
    if (selectedTab == 0) return allNoti;
    String selectedCategory = tabs[selectedTab].toLowerCase();
    return allNoti.where((noti) {
      return noti.text.toLowerCase().contains(selectedCategory) ||
          noti.type.toLowerCase().contains(selectedCategory);
    }).toList();
  }

  String calculateTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return DateFormat('MMM d').format(date);
  }

  Map<String, List<NotificationModel>> groupNotifications(List<NotificationModel> list) {
    Map<String, List<NotificationModel>> groups = {};
    for (var item in list) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      String label = itemDate == today ? "Today" : itemDate == yesterday ? "Yesterday" : DateFormat('MMMM d, yyyy').format(itemDate);
      if (groups[label] == null) groups[label] = [];
      groups[label]!.add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => closeOpenedTile(),
      child: Scaffold(
        backgroundColor: const Color(0xff010702),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          //   onPressed: () => context.read<ParentScreenProvider>().setIndex(0),
          // ),
          title: const Text("Notifications", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>SettingScreen()));
            }, icon: const Icon(Icons.settings, color: Colors.white)),
          ],
        ),
        body: Consumer<AlertProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));

            final filteredList = getFilteredList(provider.notifications);
            final groupedData = groupNotifications(filteredList);

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.greenAccent,
                    onRefresh: () async {
                      closeOpenedTile(); 
                      await provider.fetchNotifications(isRefresh: true);
                    },
                    child: filteredList.isEmpty
                        ? ListView(children: const [SizedBox(height: 100), Center(child: Text("No notifications found", style: TextStyle(color: Colors.white54)))])
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: groupedData.keys.length,
                            itemBuilder: (context, index) {
                              String dateLabel = groupedData.keys.elementAt(index);
                              List<NotificationModel> items = groupedData[dateLabel]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(dateLabel, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  ...items.map((noti) {
                                    final id = noti.id.toString();
                                    return SlidableNotificationTile(
                                      key: Key(id),
                                      noti: noti,
                                      isOpened: openedNotificationId == id,
                                      timeAgo: calculateTimeAgo(noti.createdAt),
                                      onSwipe: () {
                                        if (openedNotificationId != id) {
                                          setState(() => openedNotificationId = id);
                                        }
                                      },
                                      onDelete: () => _confirmDelete(context, noti),
                                      onTap: () {
                                        closeOpenedTile();
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(shoutId: noti.entityId, postId: noti.id)));
                                      },
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NotificationModel noti) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), color: const Color(0xff1b1b1b)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to delete this notification?", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.r, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 25.h),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("No", style: TextStyle(color: Colors.white54, fontSize: 14.r)))),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Consumer<AlertDeleteProvider>(
                      builder: (context, deleteProvider, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                          onPressed: deleteProvider.isLoading
                              ? null
                              : () async {
                                  bool isDeleted = await deleteProvider.notifyDelete(id: noti.id.toString());
                                  if (isDeleted) {
                                    if (mounted) Navigator.pop(context);
                                    context.read<AlertProvider>().removeNotificationLocally(noti.id.toString());
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(deleteProvider.success ?? "Deleted successfully")));
                                  }
                                },
                          child: deleteProvider.isLoading
                              ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text("Yes", style: TextStyle(color: Colors.white, fontSize: 14.r)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlidableNotificationTile extends StatefulWidget {
  final NotificationModel noti;
  final String timeAgo;
  final bool isOpened;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onSwipe;

  const SlidableNotificationTile({
    super.key,
    required this.noti,
    required this.isOpened,
    required this.timeAgo,
    required this.onDelete,
    required this.onTap,
    required this.onSwipe,
  });

  @override
  State<SlidableNotificationTile> createState() => _SlidableNotificationTileState();
}

class _SlidableNotificationTileState extends State<SlidableNotificationTile> {
  double _offset = 0;
  final double _deleteBtnWidth = 80.0;

  @override
  void didUpdateWidget(covariant SlidableNotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpened && _offset != 0) {
      setState(() {
        _offset = 0;
      });
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0) {
      widget.onSwipe(); 
    }
    setState(() {
      _offset += details.delta.dx;
      if (_offset > 0) _offset = 0;
      if (_offset < -_deleteBtnWidth - 10) _offset = -_deleteBtnWidth - 10;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      if (_offset < -_deleteBtnWidth / 2) {
        _offset = -_deleteBtnWidth;
      } else {
        _offset = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (widget.noti.type) {
      case 'comment': icon = Icons.chat_bubble_outline; break;
      case 'echo': icon = Icons.campaign_outlined; break;
      default: icon = Icons.notifications_none;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container( 
                  width: _deleteBtnWidth,
             
                  decoration: BoxDecoration(
                    color: Colors.redAccent, 
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: const Center(child: Icon(Icons.delete, color: Colors.white)),
                ),
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(_offset, 0, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff121212),
                borderRadius: BorderRadius.circular(15),
                border: widget.noti.readAt == null ? Border.all(color: Colors.greenAccent.withOpacity(0.2)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundColor: const Color(0xff031406), radius: 20, child: Icon(icon, color: Colors.greenAccent, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.noti.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(widget.noti.text, style: const TextStyle(color: Colors.white54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.timeAgo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}