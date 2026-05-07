import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:jwells/features/profile/presentation/viewmodel/change_password_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  void _submitChangePassword() async {
    final changePassProvider = context.read<ChangePasswordProvider>();
    final userProvider = context.read<CustomAppBarProvider>();

    String oldPass = _currentPasswordController.text.trim();
    String newPass = _newPasswordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();
    String email = userProvider.data?.email ?? "";

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showErrorSnackBar("All fields are required!");
      return;
    }

    if (oldPass == newPass) {
      _showErrorSnackBar("New password cannot be the same as current password!");
      return;
    }

    
    if (newPass != confirmPass) {
      _showErrorSnackBar("New passwords do not match!");
      return;
    }

  
    if (newPass.length < 8) {
      _showErrorSnackBar("Password must be at least 8 characters long!");
      return;
    }

  
    bool success = await changePassProvider.changePassAccount(
      email: email,
      oldpass: oldPass,
      newpass: newPass,
    );

    if (success) {
     
      _showSnackBar("Password changed successfully!", Colors.green);
      
 
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, RouteNames.parentScreen, (route) => false);
      });
    } else {
      _showErrorSnackBar(changePassProvider.errorMessage ?? "Operation Failed");
    }
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xff0D1F15), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Change Password", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
              SizedBox(height: 32.h),

              Text("Set New Password", style: TextStyle(fontSize: 24.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              Text("Make sure it's strong and unique to keep your account secure.", style: TextStyle(fontSize: 14.sp, color: Colors.white60)),
              SizedBox(height: 32.h),

              _buildLabel("Current Password"),
              _buildPasswordField(
                controller: _currentPasswordController,
                hintText: "Enter current password",
                isObscure: _isCurrentPasswordObscure,
                onToggle: () => setState(() => _isCurrentPasswordObscure = !_isCurrentPasswordObscure),
              ),
              
              SizedBox(height: 24.h),
              _buildLabel("New Password"),
              _buildPasswordField(
                controller: _newPasswordController,
                hintText: "Enter new password",
                isObscure: _isNewPasswordObscure,
                onToggle: () => setState(() => _isNewPasswordObscure = !_isNewPasswordObscure),
              ),
              
              SizedBox(height: 24.h),
              _buildLabel("Confirm New Password"),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: "Re-type new password",
                isObscure: _isConfirmPasswordObscure,
                onToggle: () => setState(() => _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
              ),

              SizedBox(height: 40.h),
              Consumer<ChangePasswordProvider>(
                builder: (context, provider, child) {
                  return GestureDetector(
                    onTap: provider.isloading ? null : _submitChangePassword,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xff3CF084),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      alignment: Alignment.center,
                      child: provider.isloading 
                        ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text("Save Changes", style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(label, style: TextStyle(color: Colors.white, fontSize: 15.sp)),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      obscuringCharacter: '●',
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white24, fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xff121212),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 20.w),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: const BorderSide(color: Color(0xff3CF084), width: 1)),
      ),
    );
  }
}