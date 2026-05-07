import 'dart:async'; // 1. এই প্যাকেজটি ইমপোর্ট করতে হবে স্ট্রিমের জন্য
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/auth/model_view/forgot_screen_provider.dart';
import 'package:jwells/features/auth/model_view/fotget_verify_provider.dart';
import 'package:jwells/features/auth/model_view/resend_code_provider.dart';
import 'package:jwells/features/auth/presentation/views/screens/set_new_password_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordOtpScreen({super.key, this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);

  final TextEditingController _otpController = TextEditingController();

  late StreamController<ErrorAnimationType> errorController;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    _otpController.dispose();
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FotgetVerifyProvider>();

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  
                },
              ),
              SizedBox(height: 30.h),
              Text(
                'Enter OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                'We have just sent you 6 digit code via your\nemail ${widget.email}',
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
                    onTap: () async {
                      if (verifyProvider.isLoading) return;

                      if (_otpController.text.length != 6) {
                        errorController.add(ErrorAnimationType.shake);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter full 6-digit OTP"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      bool isVerified = await verifyProvider.forgotverify(
                        email: widget.email.toString(),
                        otp: _otpController.text,
                      );

                      if (isVerified) {
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetNewPasswordScreen(
                              email: widget.email.toString(),
                              otp: _otpController.text,
                            ),
                          ),
                          (routes) => false,
                        );
                      } else {
                        errorController.add(ErrorAnimationType.shake);

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              verifyProvider.errorMessage ??
                                  "Invalid OTP! Try again.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );

                        //_otpController.clear();
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20.h),
              _buildResendCodeLink(),
            ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      ),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.circle,
        borderRadius: BorderRadius.circular(30.r),
        fieldHeight: 40.h,
        fieldWidth: 40.w,
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
    );
  }

  Widget _buildResendCodeLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Didn\'t receive code? ',
            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
          ),
          Consumer<ResendCodeProvider>(
            builder: (context, provider, child) {
              return TextButton(
                // Disable button if loading
                onPressed: provider.isloading
                    ? null
                    : () async {
                     
                        final isSuccess = await provider.resendcode(
                          email: widget.email.toString(),
                        );

                  
                        if (!context.mounted) return;

                        // 3. Show feedback
                        if (isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.successmessage ?? "Code sent!",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errormessage ?? "Failed to send code",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: Text(
                  provider.isloading ? "Loading..." : "Resend Code",
                  style: TextStyle(
                    // Change color to grey if loading to look disabled
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
