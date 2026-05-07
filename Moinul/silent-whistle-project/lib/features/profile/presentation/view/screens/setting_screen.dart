import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:jwells/features/payment/presentation/view/screens/select_subscription_plan_screen.dart';
import 'package:jwells/core/services/local_storage_service/location_storage.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';
import 'package:jwells/features/profile/presentation/view/screens/blocked_users_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/privacy_policy.dart';
import 'package:jwells/features/profile/presentation/view/screens/security_setting_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/support_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/terms_of_service_screen.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/update_profile_picture_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final ImagePicker _picker = ImagePicker();
  final LocationStorage _locationStorage = LocationStorage();
  String? _savedLocationText;

  @override
  void initState() {
    super.initState();
    // Fetch latest user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomAppBarProvider>().fetchAppBar();
    });
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final savedLocation = await _locationStorage.getLocationText();
    if (!mounted) return;
    setState(() {
      _savedLocationText = savedLocation;
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xff00d09c),
            ),
          ),
        );

        // Upload image
        final updateProvider = context.read<UpdateUserProvider>();
        final success = await updateProvider.updateImage(image);

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (success && mounted) {
          // Refresh user data
          await context.read<CustomAppBarProvider>().fetchAppBar();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Color(0xff00d09c),
            ),
          );
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updateProvider.errorMessage ?? 'Failed to update profile picture',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TokenStorage tokenStorage = TokenStorage();
    final userData = Provider.of<CustomAppBarProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50), // Balance the back button
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Profile Header with border matching profile screen
                    Column(
                      children: [
                        // Profile Picture with Green Border and Camera Icon
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff00d09c),
                                  width: 2.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: userData.data?.avatar != null &&
                                    userData.data!.avatar!.isNotEmpty
                                    ? Image.network(
                                  userData.data!.avatar!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
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
                                  decoration: const BoxDecoration(
                                    color: Color(0xff0D1F15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),

                            // Camera Icon Overlay
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff00d09c),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xff010702),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          userData.data?.name ?? "N/A",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Location
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xff00d09c),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _buildLocationText(userData.data),
                              style: const TextStyle(
                                color: Color(0xff00d09c),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                  
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Container(
                    //     padding: const EdgeInsets.all(14),
                    //     decoration: BoxDecoration(
                    //       color: const Color(0xff0D1F15),
                    //       borderRadius: BorderRadius.circular(12),
                    //       border: Border.all(
                    //         color: Colors.white.withOpacity(0.05),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Container(
                    //           padding: const EdgeInsets.all(10),
                    //           decoration: const BoxDecoration(
                    //             color: Color(0xff031409),
                    //             shape: BoxShape.circle,
                    //           ),
                    //           child: const Icon(
                    //             Icons.location_on_outlined,
                    //             color: Color(0xff00d09c),
                    //             size: 20,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 14),
                    //         // Expanded(
                    //         //   child: Column(
                    //         //     crossAxisAlignment: CrossAxisAlignment.start,
                    //         //     children: [
                    //         //       const Text(
                    //         //         "Include Location",
                    //         //         style: TextStyle(
                    //         //           color: Colors.white,
                    //         //           fontSize: 16,
                    //         //           fontWeight: FontWeight.w500,
                    //         //         ),
                    //         //       ),
                    //         //       const SizedBox(height: 2),
                    //         //       Text(
                    //         //         _buildLocationText(userData.data),
                    //         //         style: const TextStyle(
                    //         //           color: Colors.grey,
                    //         //           fontSize: 13,
                    //         //         ),
                    //         //       ),
                    //         //     ],
                    //         //   ),
                    //         // ),
                    //         CupertinoSwitch(
                    //           value: true,
                    //           activeColor: const Color(0xff00d09c),
                    //           onChanged: (bool value) {
                    //             // TODO: Handle location toggle
                    //           },
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                   

                    // Account Section
                    _buildSectionHeader("Account"),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.person_outline,
                      title: "Personal Info",
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.personalInfo);
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: "Account Settings",
                      onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>SecuritySettingsScreen()));
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.payment_outlined,
                      title: "Subscription & Payment",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentMethodScreen(
                              onPurchaseSuccess: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subscription updated'),
                                    backgroundColor: Color(0xff00d09c),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.block_outlined,
                      title: "Blocked Users",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BlockedUsersScreen(),
                          ),
                        );
                      },
                    ),
                    // _buildMenuItem(
                    //   context: context,
                    //   icon: Icons.notifications_outlined,
                    //   title: "Push Notification",
                    //   onTap: () {
                    //     Navigator.push(context, MaterialPageRoute(builder: (_)=>PushNotificationScreen()));
                    //   },
                    // ),

                    const SizedBox(height: 32),

                    // Support Section
                    _buildSectionHeader("Support"),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      title: "Support",
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_)=>SupportScreen()));
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_)=>PrivacyPolicyScreen()));
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.description_outlined,
                      title: "Terms of Service",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>TermsOfServiceScreen()));
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirmed = await _showLogoutConfirmation(context);
                    if (confirmed == true) {
                      await tokenStorage.clearToken();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.loginScreen,
                              (route) => false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00d09c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildLocationText(dynamic data) {
    if (data == null) return "Location not set";

    try {
      List<String> parts = [];

      // Try to get 'address' field first (from CustomAppBarProvider)
      try {
        if (data.address != null && data.address.toString().trim().isNotEmpty) {
          return data.address.toString();
        }
      } catch (_) {
        // address field doesn't exist, continue
      }

      // Try city, state, country fields (from Profile model)
      try {
        if (data.city != null && data.city.toString().trim().isNotEmpty) {
          parts.add(data.city.toString());
        }
      } catch (_) {
        // city field doesn't exist
      }

      try {
        if (data.state != null && data.state.toString().trim().isNotEmpty) {
          parts.add(data.state.toString());
        }
      } catch (_) {
        // state field doesn't exist
      }

      try {
        if (data.country != null && data.country.toString().trim().isNotEmpty) {
          parts.add(data.country.toString());
        }
      } catch (_) {
        // country field doesn't exist
      }

      // If we have parts, join them
      if (parts.isNotEmpty) {
        return parts.join(", ");
      }
    } catch (e) {
      debugPrint('Error building location text: $e');
    }

    return _savedLocationText ?? "Location not set";
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xff0D1F15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1F15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff00d09c).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xff00d09c),
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
}
