import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwells/features/map/screen/view/map_details_screen.dart';
import 'package:jwells/features/map/screen/view_model/map_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_save_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultLatLng = LatLng(23.8103, 90.4125);
  bool isSearching = false;
  bool showSearchAndList = false;
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  LatLng? _currentLatLng;
  bool _hasLocationAccess = false;
  String? _locationStatusMessage;

  @override
  void initState() {
    super.initState();
    _currentLatLng = _defaultLatLng;
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _hasLocationAccess = false;
          _locationStatusMessage =
              "Location is turned off. You can still browse and save places manually.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _hasLocationAccess = false;
            _locationStatusMessage =
                "Location permission denied. You can still use the map without your live location.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _hasLocationAccess = false;
          _locationStatusMessage =
              "Location permission is blocked in settings. Other map features are still available.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        _hasLocationAccess = true;
        _locationStatusMessage = null;
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });

      if (_mapController != null && _currentLatLng != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLatLng!, 15),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLocationAccess = false;
        _locationStatusMessage =
            "Your current location couldn't be loaded. You can continue with manual location selection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final bool isPremium =
        context.watch<CustomAppBarProvider>().isPremimum == true;

    Set<Marker> markers = {};
    if (mapProvider.selectedLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId(
            mapProvider.selectedLocation!.placeId ?? "selected",
          ),
          position: LatLng(
            mapProvider.selectedLocation!.latitude!,
            mapProvider.selectedLocation!.longitude!,
          ),
          infoWindow: InfoWindow(title: mapProvider.selectedLocation!.name),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                mapProvider.onMapCreated(controller);
              },
              markers: markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: _hasLocationAccess,
              mapType: MapType.normal,
            ),
          ),
          if (_locationStatusMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _locationStatusMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),

          Positioned(
            bottom: 200,
            right: 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapDetailsScreen()),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xff010702),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSearching)
                    GestureDetector(
                      onTap: () => setState(() => isSearching = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff121212),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_location_alt, color: Color(0xff29D862), size: 20),
                            SizedBox(width: 10),
                            Text("Add to Location", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),

                  if (isSearching)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xff121212),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white54, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.search,
                              onChanged: (value) async {
                                if (value.isNotEmpty) {
                                  setState(() => showSearchAndList = true);
                                  if (isPremium) {
                                    await mapProvider.searchPlaces(value);
                                  }
                                } else {
                                  setState(() => showSearchAndList = false);
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "Search Area",
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isSearching && showSearchAndList)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Flexible(
                            child: mapProvider.isLoading
                                ? const Center(child: CircularProgressIndicator(color: Color(0xff29D862)))
                                : !isPremium
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Text(
                                      "Please buy a subscription to search.",
                                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                                    ),
                                  )
                                : (mapProvider.mapModel?.data == null || mapProvider.mapModel!.data!.isEmpty)
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      mapProvider.errorMessage ?? "No results found",
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: mapProvider.mapModel?.data?.length ?? 0,
                                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final location = mapProvider.mapModel!.data![index];
                                      return GestureDetector(
                                        onTap: () {
                                          mapProvider.selectLocation(location);
                                          _searchController.text = location.name ?? "";
                                          setState(() => showSearchAndList = false);
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: _buildLocationItem(
                                          title: location.name ?? "",
                                          address: location.address ?? "",
                                          isSelected: mapProvider.selectedLocation?.placeId == location.placeId,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                  if (isSearching && isPremium) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Consumer<MapSaveProvider>(
                        builder: (context, savePovider, child) {
                          return ElevatedButton(
                            onPressed: savePovider.isloading
                                ? null
                                : () async {
                                    if (mapProvider.selectedLocation != null) {
                                      final selected = mapProvider.selectedLocation!;
                                      bool success = await savePovider.saveMapLocation(
                                        name: selected.name ?? "",
                                        address: selected.address ?? "",
                                        latitude: selected.latitude ?? 0.0,
                                        longitude: selected.longitude ?? 0.0,
                                        placeId: selected.placeId ?? "",
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success 
                                              ? (savePovider.successMessage ?? "Location Saved!") 
                                              : (savePovider.errorMessage ?? "Failed to save location")
                                            ),
                                            backgroundColor: success ? Colors.green : Colors.red,
                                          ),
                                        );
                                        if (success) {
                                          setState(() {
                                            isSearching = false;
                                            _searchController.clear();
                                          });
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff29D862),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                            ),
                            child: savePovider.isloading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text("Save to Location", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({required String title, required String address, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff0E0E0E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? const Color(0xff29D862) : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(address, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xff29D862), size: 20),
        ],
      ),
    );
  }
}
