import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationScreen extends StatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  State<PushNotificationScreen> createState() => _PushNotificationScreenState();
}

class _PushNotificationScreenState extends State<PushNotificationScreen> {
  Map<String, bool> settings = {
    "New Announcements": true,
    "Payment Reminders": true,
    "Course Availability": false,
    "Community Mentions": true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }


  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      settings.keys.forEach((key) {
        settings[key] = prefs.getBool(key) ?? settings[key]!;
      });
    });
  }


  _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
    setState(() {
      settings[key] = value;
    });
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
              _buildHeader(context, "Push Notification"),
              SizedBox(height: 30.h),
              ...settings.entries.map((entry) => _buildToggleItem(entry.key, entry.value)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, bool value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          Switch(
            value: value,
            activeColor: const Color(0xff3CF084),
            activeTrackColor: const Color(0xff3CF084).withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            onChanged: (val) => _saveSetting(title, val),
          ),
        ],
      ),
    );
  }
}


Widget _buildHeader(BuildContext context, String title) {
  return Row(
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
          child: Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        ),
      ),
      SizedBox(width: 40.w),
    ],
  );
}