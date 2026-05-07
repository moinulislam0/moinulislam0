import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/profile/presentation/view/widgets/build_header.dart';
import 'package:jwells/features/profile/presentation/viewmodel/support_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportOption {
  final String title;
  final String description;
  final String hint;
  final bool isFeedbackType;

  SupportOption({
    required this.title,
    required this.description,
    required this.hint,
    this.isFeedbackType = false,
  });
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const String _supportEmail = 'Support@silentwhistle.app';
  
  final TextEditingController messageController = TextEditingController();

  final List<SupportOption> supportOptions = [
    SupportOption(
      title: "Account or Login Issues",
      description: "If you're having trouble logging in, please try resetting your password first. If the issue persists, ensure your app is updated to the latest version.",
      hint: "",
    ),
    SupportOption(
      title: "Payment & Billing",
      description: "We support IAP . If your payment was deducted but the course isn't active, please keep your transaction ID ready.",
      hint: "",
    ),
    SupportOption(
      title: "Technical Support",
      description: "Report bugs or technical glitches in the app. We will look into it immediately.",
      hint: "Example: The video player is not loading...",
      isFeedbackType: true,
    ),
    SupportOption(
      title: "General Inquiry",
      description: "Anything else you want to ask us.",
      hint: "Type your question here...",
      isFeedbackType: true,
    ),
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BuildHeader(title: "Support"),
                SizedBox(height: 30.h),
                Text("Need Help?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10.h),
                Text(
                    "Select a topic below to see answers or contact the admin. We're here to assist you.",
                    style: TextStyle(color: Colors.white54, fontSize: 14.sp)),
                SizedBox(height: 30.h),
                _buildContactCard(),
                SizedBox(height: 20.h),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff121212),
                    borderRadius: BorderRadius.circular(20.r),

                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        highlightColor: Colors.transparent
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: supportOptions.length,
                      separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withOpacity(0.05), height: 1),
                      itemBuilder: (context, index) {
                        final option = supportOptions[index];
                        return ExpansionTile(
                            //splashColor: Colors.transparent,

                            iconColor: Colors.white54,
                            collapsedIconColor: Colors.white24,
                            onExpansionChanged: (isExpanded) {

                              if (isExpanded) messageController.clear();
                            },
                            title: Text(
                              option.title,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.sp),
                            ),
                            childrenPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            expandedAlignment: Alignment.topLeft,
                            children: [
                              Text(
                                option.description,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14.sp),
                              ),

                              if (option.isFeedbackType) ...[
                                SizedBox(height: 15.h),
                                TextField(
                                  controller: messageController,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: option.hint,
                                    hintStyle: TextStyle(
                                        color: Colors.white24, fontSize: 13.sp),
                                    filled: true,
                                    fillColor: const Color(0xff1a1a1a),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),

                                Consumer<SupportProvider>(
                                  builder: (context, provider, child) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 45.h,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.greenAccent.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.r),
                                          ),
                                        ),
                                        onPressed: provider.isloading ? null : () async {

                                          final String messageText = messageController.text.trim();
                                          if (messageText.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Please enter your message!"),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            return;
                                          }


                                          FocusScope.of(context).unfocus();


                                          final bool success = await provider.support(
                                            subject: option.title,
                                            message: messageText,
                                          );


                                          log("Subject Selected: ${option.title}");


                                          if (success) {
                                            messageController.clear();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(provider.successMessage ?? "Sent successfully!"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(provider.errorMessage ?? "Failed to send"),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
                                        },
                                        child: provider.isloading
                                            ? const SizedBox(
                                          height: 20, width: 20,
                                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                        )
                                            : Text(
                                          "Send Message",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10.h),
                              ]
                            ]
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Us",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Report inappropriate activity directly using the details below.",
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 14.h),
          InkWell(
            onTap: () => launchUrl(Uri.parse('mailto:$_supportEmail')),
            child: Text(
              "Email: $_supportEmail",
              style: TextStyle(
                color: Colors.greenAccent.shade700,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          
        ],
      ),
    );
  }
}
