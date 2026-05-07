import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/core/services/local_storage_service/token_storage.dart';
import '../../core/constant/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    final token = await _tokenStorage.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, RouteNames.parentScreen);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.onboardingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI remains unchanged
    const Color darkGreenStart = Color.fromARGB(255, 0, 50, 0);
    const Color darkGreenEnd = Color.fromARGB(255, 0, 70, 0);
    const Color logoAccent = Color.fromARGB(255, 76, 175, 80);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [darkGreenStart, darkGreenEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100.w,
                height: 100.h,
                child: Image.asset(
                  'assets/icons/logo.png',
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: darkGreenEnd,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: logoAccent, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'SP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Silent Whistle',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(logoAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
