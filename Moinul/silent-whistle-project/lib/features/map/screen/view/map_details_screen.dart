import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/map/screen/view_model/map_get_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_delete_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_provider.dart'; // Import MapProvider
import 'package:provider/provider.dart';

class MapDetailsScreen extends StatefulWidget {
  const MapDetailsScreen({super.key});

  @override
  State<MapDetailsScreen> createState() => _MapDetailsScreenState();
}

class _MapDetailsScreenState extends State<MapDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapGetProvider>().showDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Saved Locations", style: TextStyle(color: Colors.white, fontSize: 18.sp)),
      ),
      body: SafeArea(
        child: Consumer<MapGetProvider>(
          builder: (context, provider, child) {
            if (provider.isloading) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }

            final items = provider.mapDetails.data ?? [];

            if (items.isEmpty) {
              return const Center(child: Text("No locations saved", style: TextStyle(color: Colors.white)));
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () {
                   
                    context.read<MapProvider>().moveToSavedLocation(
                      lat: double.parse(item.latitude.toString()),
                      lng: double.parse(item.longitude.toString()),
                      name: item.name ?? "",
                      address: item.address ?? "",
                    );
                  
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 30.h, width: 30.w,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                          child: Text("${index + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? "N/A", 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)
                              ),
                              Text(
                                item.address ?? "N/A", 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: TextStyle(color: Colors.white70, fontSize: 13.sp)
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.white, size: 24.sp),
                          color: const Color(0xFF2E2E2E),
                          onSelected: (value) async {
                            if (value == 'delete') {
                              bool success = await context.read<MapDeleteProvider>().deleteMapDetails(id: item.id.toString());
                              if (success && context.mounted) {
                                context.read<MapGetProvider>().showDetails();
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}