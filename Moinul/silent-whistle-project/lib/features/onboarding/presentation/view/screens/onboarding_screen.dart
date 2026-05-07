import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../app/widgets/buttons/primary_button.dart';
import '../../../../../core/constant/route_names.dart';
import '../../../../../core/services/local_storage_service/location_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final LocationStorage _locationStorage = LocationStorage();
  int currentIndex = 0;

  bool _isLocationGranted = false;
  bool _isMicrophoneGranted = false;

  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);
  static const Color iconBackground = Color.fromARGB(255, 30, 30, 30);
  static const Color cardBackground = Color.fromARGB(255, 10, 10, 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      _syncAllPermissions();
    }
  }

  Future<void> _syncAllPermissions() async {
    await _syncLocationPermissionState();
    await _syncMicrophonePermissionState();
  }

  Future<void> _syncLocationPermissionState() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final LocationPermission permission = await Geolocator.checkPermission();

    if (!mounted) return;

    setState(() {
      _isLocationGranted = serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse);
    });
  }

  Future<void> _syncMicrophonePermissionState() async {
    final PermissionStatus status = await Permission.microphone.status;
    if (!mounted) return;
    setState(() {
      _isMicrophoneGranted = status.isGranted;
    });
  }


  Future<void> _handleLocationAction() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location is off. You can keep using the app without it."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('Location permission status before request: $permission');

    if (permission == LocationPermission.deniedForever) {
    debugPrint('Permission permanently denied. Redirecting to settings.');
      openAppSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('Location permission request returned: $permission');
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      try {
        final Position position = await Geolocator.getCurrentPosition();
        String? locationText;
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            place.locality,
            place.subAdministrativeArea,
            place.country,
          ].where((part) => part != null && part.trim().isNotEmpty).toList();
          if (parts.isNotEmpty) {
            locationText = parts.join(", ");
          }
        }
        await _locationStorage.saveLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          locationText: locationText,
        );
        setState(() => _isLocationGranted = true);
        debugPrint('Location recorded: (${position.latitude}, ${position.longitude})');
      } catch (e) {
        debugPrint('Location Error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't fetch location right now. You can continue without it."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission skipped. You can enable it later from settings."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  Future<void> _handleMicrophoneAction() async {
    PermissionStatus status = await Permission.microphone.status;
    debugPrint('Current microphone status: $status');

    if (status.isPermanentlyDenied) {
      debugPrint('Microphone permission permanently denied. Opening settings.');
      openAppSettings();
      return;
    }

    if (status.isDenied) {
      status = await Permission.microphone.request();
      debugPrint('Microphone permission request result: $status');
    }

    if (status.isGranted) {
      debugPrint('Microphone permission granted.');
      setState(() => _isMicrophoneGranted = true);
    }
  }

  void _goToMain(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.loginScreen,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemCount: 3,
                itemBuilder: (context, index) => _buildPageContent(index),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: _buildPageIndicator(currentPageIndex: currentIndex),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              child: PrimaryButton(
                title: currentIndex == 2 ? "Continue" : "Next",
                onTap: () {
                  if (currentIndex == 2) {
                    _goToMain(context);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    if (index == 0) {
      return _buildIntroPage(
        AppFeatureFlags.enableAnonymousPosting
            ? "Stay Anonymous"
            : "Share Responsibly",
        AppFeatureFlags.enableAnonymousPosting
            ? "Your identity is protected. Share freely with\nauto generated usernames & community\nfocused moderation."
            : "Share safely with clear community rules,\nreport and block tools, and strong\nmoderation against abusive content.",
        AppFeatureFlags.enableAnonymousPosting
            ? Icons.person_outline
            : Icons.verified_user_outlined,
      );
    }
    if (index == 1) return _buildIntroPage(
      "Connect Locally", 
      "Discover what's happening around you. Your\nlocation helps you connect with nearby\nvoices and local events.", 
      Icons.groups_outlined
    );
    return _buildPermissionPage();
  }

  Widget _buildIntroPage(String title, String desc, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _buildIconCircle(icon),
          SizedBox(height: 30.h),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 15.h),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16.sp, height: 1.5)),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildPermissionPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30.h),
            _buildIconCircle(Icons.shield_outlined, size: 80),
            SizedBox(height: 30.h),
            Text('Enable Permissions', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Text('Permissions help improve the experience,\nbut you can continue without enabling them now.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
            SizedBox(height: 40.h),
            _buildPermissionCard(
              icon: Icons.location_on_outlined,
              title: 'Location Access',
              description: 'Location helps with nearby content, but the app will still work if you skip it.',
              buttonText: _isLocationGranted ? 'Location Ready' : 'Next',
              isActive: !_isLocationGranted,
              onTap: _handleLocationAction,
            ),
            SizedBox(height: 20.h),
            // Microphone card intentionally hidden per request.
            // _buildPermissionCard(
            //   icon: Icons.mic_none,
            //   title: 'Microphone Access',
            //   description: 'Microphone access lets you record voice shouts that stay tied to your location.',
            //   buttonText: _isMicrophoneGranted ? 'Microphone Ready' : 'Enable Microphone',
            //   isActive: !_isMicrophoneGranted,
            //   onTap: _handleMicrophoneAction,
            // ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isActive ? primaryGreen : Colors.grey, size: 28.w),
              SizedBox(width: 15.w),
              Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(description, style: TextStyle(color: Colors.white70, fontSize: 14.sp, height: 1.4)),
          SizedBox(height: 15.h),
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: OutlinedButton(
              onPressed: onTap, 
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isActive ? primaryGreen : Colors.grey.shade800),
                backgroundColor: isActive ? Colors.transparent : Colors.grey.withOpacity(0.05),
              ),
              child: Text(buttonText, style: TextStyle(color: isActive ? primaryGreen : Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, {double size = 100}) {
    return Container(
      width: size.w, height: size.w,
      decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle, border: Border.all(color: primaryGreen.withOpacity(0.5))),
      child: Center(child: Icon(icon, color: primaryGreen, size: (size/2).w)),
    );
  }

  Widget _buildPageIndicator({required int currentPageIndex}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        height: 8.h, width: index == currentPageIndex ? 24.w : 8.w,
        decoration: BoxDecoration(color: index == currentPageIndex ? primaryGreen : Colors.grey.shade700, borderRadius: BorderRadius.circular(4)),
      )),
    );
  }
}
