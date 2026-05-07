import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/profile/presentation/view/screens/change_password_screen.dart';

import 'package:jwells/features/profile/presentation/viewmodel/enable_accout_provider.dart';
import 'package:provider/provider.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:jwells/features/profile/presentation/viewmodel/delete_account_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/disable_account_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  void _showActionDialog(BuildContext context, {
    required String title, 
    required String actionText, 
    required bool isDelete,
    required bool isActive, 
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<DeleteAccountProvider>()),
          ChangeNotifierProvider.value(value: context.read<DisableAccountProvider>()),
          ChangeNotifierProvider.value(value: context.read<EnableAccoutProvider>()), 
        ],
        child: Consumer3<DeleteAccountProvider, DisableAccountProvider, EnableAccoutProvider>(
          builder: (context, deleteProvider, disableProvider, enableProvider, child) {
       
            bool isLoading = isDelete 
                ? deleteProvider.isloading 
                : (isActive ? disableProvider.isloading : enableProvider.isloading);

            return Dialog(
              backgroundColor: const Color(0xff121212),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: const BoxDecoration(color: Color(0xff0D1F15), shape: BoxShape.circle),
                      child: Icon(Icons.error_outline, color: Colors.white, size: 30.w),
                    ),
                    SizedBox(height: 24.h),
                    Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.h),
                    Text("Are you sure you want to $title?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                    SizedBox(height: 32.h),
                    
                    GestureDetector(
                      onTap: isLoading ? null : () async {
                        if (isDelete) {
                          bool success = await deleteProvider.deleteAccount();
                          if (success) {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(context, RouteNames.loginScreen, (route) => false);
                          }
                        } else {
                          bool success;
                          String? msg;
                          
                          if (isActive) {
                          
                            success = await disableProvider.toggleAccountStatus();
                            msg = disableProvider.successMessage;
                          } else {
                         
                            success = await enableProvider.enableAccountStatus();
                            msg = enableProvider.successMessage;
                          }

                          if (success) {
                         
                            await context.read<CustomAppBarProvider>().fetchAppBar();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? "Success")));
                          } else {
                     
                            String error = isActive ? (disableProvider.errorMessage ?? "Failed") : (enableProvider.errorMessage ?? "Failed");
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                          color: isDelete ? const Color(0xffff3b3b) : const Color(0xff00d09c),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        alignment: Alignment.center,
                        child: isLoading 
                          ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(actionText, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (!isLoading)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(30.r), border: Border.all(color: Colors.white24)),
                          alignment: Alignment.center,
                          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context), 
                    child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xff0D1F15), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20))
                  ),
                  Expanded(child: Center(child: Text("Security Settings", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)))),
                  SizedBox(width: 40.w),
                ],
              ),
              SizedBox(height: 32.h),

              Consumer<CustomAppBarProvider>(
                builder: (context, userProvider, child) {
              
                  bool isActive = userProvider.data?.status ?? true;

                  return Container(
                    decoration: BoxDecoration(color: const Color(0xff121212), borderRadius: BorderRadius.circular(20.r)),
                    child: Column(
                      children: [
                        _buildSecurityItem(title: "Change Password", showArrow: true, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_){
                            return ChangePasswordScreen() ;
                          }));
                        }),
                        _buildDivider(),
                        
                        _buildSecurityItem(
                          title: isActive ? "Disable Account" : "Enable Account",
                          onTap: () => _showActionDialog(
                            context, 
                            title: isActive ? "Disable Account" : "Enable Account", 
                            actionText: isActive ? "Disable" : "Enable",
                            isDelete: false,
                            isActive: isActive,
                          ),
                        ),
                        
                        _buildDivider(),
                        _buildSecurityItem(
                          title: "Delete Account",
                          onTap: () => _showActionDialog(
                            context, 
                            title: "Delete Account", 
                            actionText: "Delete", 
                            isDelete: true,
                            isActive: isActive,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.white.withOpacity(0.05), height: 1, thickness: 1, indent: 20.w);

  Widget _buildSecurityItem({required String title, bool showArrow = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16.sp, fontWeight: FontWeight.w400)),
            if (showArrow) const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}