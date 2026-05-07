import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:jwells/features/auth/model_view/fotget_verify_provider.dart';
import 'package:jwells/features/auth/model_view/resend_code_provider.dart';
import 'package:jwells/features/auth/presentation/views/screens/signup_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  final String? email;
  const OTPScreen({super.key, this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);
  static const Color otpBoxBackground = Color.fromARGB(255, 10, 10, 10);

  final TextEditingController _otpController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  String? emailFromArgs;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      emailFromArgs = args;
    }
  }

  @override
  void dispose() {

    errorController?.close();
    _otpController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = widget.email ?? emailFromArgs ?? "your email";

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>SignUpScreen()),(route)=>false);
          } 
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  "We have sent a 6 digit code to\n$displayEmail",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 50.h),
                _buildOtpField(),
                SizedBox(height: 40.h),
                Consumer<FotgetVerifyProvider>(
                  builder: (context, verifyProvider, child) {
                    return PrimaryButton(
                      title: verifyProvider.isLoading ? "Verifying..." : "Verify",
                      onTap: verifyProvider.isLoading ? null : () async {
                        if (_otpController.text.length != 6) {
                          errorController?.add(ErrorAnimationType.shake);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter full 6-digit OTP"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                              bool isVerified = await verifyProvider.forgotverify(
                                email: widget.email ?? "",
                                otp: _otpController.text,
                              );

                        if (!mounted) return;

                        if (isVerified) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SuccessDialog(planName: ''),
                            ),
                                (routes) => false,
                          );
                        } else {
                          errorController?.add(ErrorAnimationType.shake);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                verifyProvider.errorMessage ?? "Invalid OTP! Try again.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 20.h),
                _buildResendCode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      controller: _otpController,
      errorAnimationController: errorController,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      cursorColor: primaryGreen,
      autoFocus: true,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.circle,
        fieldHeight: 45.h,
        fieldWidth: 45.w,
        activeFillColor: const Color(0XFF050b13),
        inactiveFillColor: const Color(0XFF050b13),
        selectedFillColor: const Color(0XFF050b13),
        activeColor: primaryGreen,
        inactiveColor: Colors.grey.withOpacity(0.3),
        selectedColor: Colors.white,
        errorBorderColor: Colors.red,
        borderWidth: 1,
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.transparent,
      enableActiveFill: true,
      onChanged: (value) {},
      beforeTextPaste: (text) => true,
    );
  }

  Widget _buildResendCode() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Didn't receive code? ",
            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
          ),
          Consumer<ResendCodeProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isloading
                    ? null
                    : () async {
                        bool isSuccess = await provider.resendcode(
                          email: widget.email ?? "",
                        );

                        if (!mounted) return;

                        if (isSuccess) {
                          _showMessage(provider.successmessage ?? "Code sent!", color: Colors.green);
                        } else {
                          _showMessage(provider.errormessage ?? "Failed to send code");
                        }
                      },
                child: Text(
                  provider.isloading ? "Loading..." : "Resend Code",
                  style: TextStyle(
                    color: provider.isloading ? Colors.grey : primaryGreen,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String planName;

  const SuccessDialog({super.key, required this.planName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1D1F2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xff38E07B), size: 64),
          const SizedBox(height: 20),
          const Text(
            "OTP Verified",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            planName.isNotEmpty
                ? "You're now subscribed to $planName."
                : 'Your account is verified.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            title: "Go to Login",
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.loginScreen,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
