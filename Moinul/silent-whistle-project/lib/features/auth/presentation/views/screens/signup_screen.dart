import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/features/auth/model_view/sign_up_screen_provider.dart';
import 'package:jwells/features/auth/presentation/views/screens/login_screen.dart';
import 'package:jwells/features/auth/presentation/views/screens/otp_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/privacy_policy.dart';
import 'package:jwells/features/profile/presentation/view/screens/terms_of_service_screen.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);
  static const Color fieldBackground = Color.fromARGB(255, 10, 10, 10);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _confirmPassError;
  bool _hasAcceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildTopSection(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please enter your details to sign up.',
                    style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                  ),
                  SizedBox(height: 30.h),

                  _buildLabel('Name'),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Enter your name',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Email'),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('UserName'),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Enter your user name',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Password'),
                  _buildPasswordField(
                    controller: _passwordController,
                    hintText: 'Password',
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: (value) {
                      setState(() => _isPasswordVisible = value);
                    },
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Confirm Password'),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    isVisible: _isConfirmPasswordVisible,
                    onToggleVisibility: (value) {
                      setState(() => _isConfirmPasswordVisible = value);
                    },
                  ),

                  if (_confirmPassError != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 5.w),
                      child: Text(
                        _confirmPassError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ),

                  SizedBox(height: 16.h),
                  _buildTermsSection(),

                  SizedBox(height: 30.h),

                  Consumer<SignUpScreenProvider>(
                    builder: (context, authProvider, child) {
                      return PrimaryButton(
                        title: authProvider.isLoading ? "Loading..." : "Sign Up",
                        onTap: authProvider.isLoading
                            ? null
                            : () async {
                                String name = _nameController.text.trim();
                                String username = _usernameController.text.trim();
                                String email = _emailController.text.trim();
                                String password = _passwordController.text.trim();
                                String confirmPass = _confirmPasswordController.text.trim();

                                if (name.isEmpty || email.isEmpty || password.isEmpty || username.isEmpty) {
                                  _showMessage("Please fill in all fields");
                                  return;
                                }

                                if (password != confirmPass) {
                                  setState(() => _confirmPassError = "Passwords do not match");
                                  return;
                                } else {
                                  setState(() => _confirmPassError = null);
                                }

                                if (!_hasAcceptedTerms) {
                                  setState(() => _showTermsError = true);
                                  return;
                                }

                                bool success = await authProvider.signUp(
                                  name: name,
                                  email: email,
                                  password: password,
                                  username: username,
                                );

                                if (context.mounted) {
                                  if (success) {
                                    _showMessage(
                                      authProvider.successMessage ?? "Registration Successful!",
                                      isError: false,
                                    );
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OTPScreen(email: email),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                  
                                    _showMessage(authProvider.errorMessage ?? "Registration failed.");
                                  }
                                }
                              },
                      );
                    },
                  ),

                  SizedBox(height: 30.h),
                  _buildDividerWithText('Or Sign In With'),
                  SizedBox(height: 30.h),
                  _buildSocialLoginButtons(),
                  SizedBox(height: 40.h),
                  _buildSignInLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      height: 0.25.sh,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 0, 50, 0), Color.fromARGB(255, 0, 70, 0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            Image.asset(
              'assets/icons/logo.png',
              width: 60.w,
              height: 60.h,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.shield, color: primaryGreen, size: 50.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              'Silent Whistle',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(15.0)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 24.w),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required ValueChanged<bool> onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(15.0)),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 24.w),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade600),
            onPressed: () => onToggleVisibility(!isVisible),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 12, 18, 12),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _showTermsError
                  ? Colors.redAccent.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(-4.w, -2.h),
                child: Checkbox(
                  value: _hasAcceptedTerms,
                  activeColor: primaryGreen,
                  checkColor: Colors.black,
                  side: const BorderSide(color: Colors.white54),
                  onChanged: (value) {
                    setState(() {
                      _hasAcceptedTerms = value ?? false;
                      if (_hasAcceptedTerms) {
                        _showTermsError = false;
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms Acceptance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      children: [
                        Text(
                          'I agree to the ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsOfServiceScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Terms of Service (EULA)',
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ),
                        Text(
                          ' and ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ),
                        Text(
                          '.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Zero tolerance policy: objectionable content, harassment, or abusive behavior toward any user is prohibited and may lead to an immediate ban.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12.5.sp,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showTermsError)
          Padding(
            padding: EdgeInsets.only(left: 12.w, top: 8.h),
            child: Text(
              'You must accept the Terms of Service to continue.',
              style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous always-visible social auth buttons kept here for reference.
        // _buildSocialButton(icon: Icons.account_circle, onPressed: () {}),
        // SizedBox(width: 30.w),
        // _buildSocialButton(icon: Icons.apple, onPressed: () {}),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          _buildSocialButton(icon: Icons.account_circle, onPressed: () {}),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
          _buildSocialButton(icon: Icons.apple, onPressed: () {}),
      ],
    );
  }

  Widget _buildSocialButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 30.w), onPressed: onPressed),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ', style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Sign in',
              style: TextStyle(color: primaryGreen, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
