import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/profile/presentation/view/widgets/build_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              BuildHeader(title:  "Privacy Policy"),
              SizedBox(height: 30.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "Welcome to Silent whistle (\"Company\", \"we\", \"our\", or \"us\"). \n\n"
                    "We value your privacy and are committed to protecting your personal information. "
                    "This Privacy Policy explains how we collect, use, store, and protect your data "
                    "when you use our website, services, or interact with us.",
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