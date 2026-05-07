import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/features/auth/model_view/new_password_verify.dart';
import 'package:jwells/features/auth/presentation/views/dialog/build_successful_dialog.dart';
import 'package:jwells/features/auth/presentation/views/screens/forgot_password_otp_screen.dart';
import 'package:provider/provider.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String? otp;
  final String? email;
  const SetNewPasswordScreen({super.key, this.email, this.otp});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  // Define colors for consistency
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color fieldBackground = Color.fromARGB(255, 10, 10, 10);

  // Controller 1: New Password
  final TextEditingController _passwordController = TextEditingController();
  // Controller 2: Confirm Password
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State to manage password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Error Text States
  String? _passError; // Error for the first field
  String? _confirmPassError; // Error for the second field

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordOtpScreen(),
                      ),
                      (routes) => false,
                    );
                  },
                ),
                SizedBox(height: 30.h),

                // 2. Title
                Text(
                  'Set New Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.h),

                // 3. Description
                Text(
                  'Your new password must be different from previous used passwords.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40.h),

                // 4. New Password Field
                _buildLabel('New Password'),
                _buildPasswordField(
                  controller: _passwordController,
                  hintText: 'Enter new password',
                  isVisible: _isPasswordVisible,
                  errorText: _passError,
                  onToggleVisibility: (value) {
                    setState(() => _isPasswordVisible = value);
                  },
                ),
                SizedBox(height: 20.h),

                // 5. Confirm Password Field
                _buildLabel('Confirm Password'),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Re-enter password',
                  isVisible: _isConfirmPasswordVisible,
                  errorText: _confirmPassError,
                  onToggleVisibility: (value) {
                    setState(() => _isConfirmPasswordVisible = value);
                  },
                ),
                SizedBox(height: 40.h),

                // 6. Update Button with Logic
                Consumer<NewPasswordVerify>(
                  builder: (context, provider, child) {
                    return PrimaryButton(
                      title: provider.isLoading
                          ? "Loading..."
                          : "Update password",
                      onTap: () async {
                        // 1. Reset Errors initially
                        setState(() {
                          _passError = null;
                          _confirmPassError = null;
                        });

                        String newPassword = _passwordController.text.trim();
                        String confirmPassword = _confirmPasswordController.text.trim();

                        // 2. Check Empty Fields
                        if (newPassword.isEmpty || confirmPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill in both fields"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        
                        if (newPassword != confirmPassword) {
                          setState(() {
                            _confirmPassError = "Passwords do not match";
                          });
                          return;
                        }

                        // 4. If Matches, Call API
                        bool success = await provider.newPassVerify(
                          email: widget.email.toString(),
                          otp: widget.otp.toString(),
                          newPass: newPassword,
                        );

                        if (success && context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  buildSuccessfulDialog(context),
                            ),
                            (routes) => false,
                          );
                        } else {
                          setState(() {
                            // API Error showing on first field or general
                            _passError = provider.errorMessage ?? "Update failed";
                          });
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Label Widget
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Custom Password Field Widget
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required ValueChanged<bool> onToggleVisibility,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: fieldBackground,
            borderRadius: BorderRadius.circular(15.0),
            border: errorText != null
                ? Border.all(color: Colors.redAccent, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            keyboardType: TextInputType.visiblePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: errorText != null
                    ? Colors.redAccent
                    : Colors.grey.shade600,
                size: 24.w,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: () => onToggleVisibility(!isVisible),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 18.h,
                horizontal: 10.w,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 5.w),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}