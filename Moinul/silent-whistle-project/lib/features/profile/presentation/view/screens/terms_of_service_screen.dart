import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/profile/presentation/view/widgets/build_header.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
          BuildHeader( title:"Terms of service"),
              SizedBox(height: 30.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "Welcome to Silent Whistle. These Terms of Service (\"Terms\") govern your access to "
                    "and use of our app, website, and related services.\n\n"
                    "By creating an account, posting content, or using the Service, you agree to follow these Terms. "
                    "If you do not agree, you must not use the Service.\n\n"
                    "User Content Rules\n"
                    "1. You must not post objectionable, abusive, hateful, threatening, sexually explicit, violent, harassing, or otherwise harmful content.\n"
                    "2. You must not insult, bully, threaten, harass, or abuse any other user.\n"
                    "3. You must not use the Service to target, shame, or intimidate individuals or groups.\n\n"
                    "Enforcement Policy\n"
                    "If you post objectionable content or abuse, harass, or threaten another user, your account may be suspended or banned immediately without prior warning.\n\n"
                    "By continuing to use Silent Whistle, you confirm that you understand and accept this zero-tolerance policy.",
                    style: TextStyle(color: Colors.white70, fontSize: 15.sp, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
