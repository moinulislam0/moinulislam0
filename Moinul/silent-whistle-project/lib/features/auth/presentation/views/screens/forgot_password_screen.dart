import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:jwells/features/auth/model/forgot_password_model.dart';
import 'package:jwells/features/auth/model_view/forgot_screen_provider.dart';
import 'package:jwells/features/auth/presentation/views/screens/forgot_password_otp_screen.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Define colors for consistency
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);
  static const Color fieldBackground = Color.fromARGB(255, 10, 10, 10);

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotScreenProvider>();
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 30.h),

              // 2. Title
              Text(
                'Forgot Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40.h),

              // 3. Email Label
              _buildLabel('Email'),

              // 4. Email Text Field
              _buildEmailField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
              ),
              SizedBox(height: 40.h),

              // 5. Send Button
              Consumer<ForgotScreenProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    title: provider.isLoading ? "loading..." : "Send",
                    onTap: () async {
                      final email = _emailController.text.trim();

                      // --- Validation Start ---
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter your email"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      ).hasMatch(email);

                      if (!emailValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid email address"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      await provider.forgotPass(email: email);

                      if (provider.successMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.successMessage!),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordOtpScreen(
                              email: _emailController.text,
                            ),
                          ),
                          (routes) => false,
                        );
                      } else if (provider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.errorMessage!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
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

  // Custom Email Text Field Widget
  Widget _buildEmailField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 24.w),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 18.h,
            horizontal: 16.w,
          ),
        ),
      ),
    );
  }
}
