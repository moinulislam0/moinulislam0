import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/core/constant/route_names.dart';

// Define the core colors used in the app
const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);
const Color dialogBackground = Color.fromARGB(255, 10, 10, 10); // Slightly off-black for the dialog card

// --- Function to build the Successful Login Dialog ---
Widget buildSuccessfulDialog(BuildContext context) {
  return Dialog(
    // Define the shape with rounded corners
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    // Use Material to explicitly ensure background color and clipping
    child: Material(
      color: dialogBackground,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep the content size minimal
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. Success Icon (Placeholder for a checkmark, or use a custom asset)
            Icon(
              Icons.check_circle_outline,
              color: primaryGreen,
              size: 60.w,
            ),
            SizedBox(height: 20.h),

            // 2. Title
            Text(
              'Successful',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15.h),

            // 3. Sub-text / Confirmation Message
            Text(
              'You have logged in successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40.h),

            // 4. "Go to Home" Button
            PrimaryButton(title: "Go to home", onTap: () {
              Navigator.pushNamed(context, RouteNames.parentScreen);
            })
          ],
        ),
      ),
    ),
  );
}


// --- Function to Show the Dialog ---
void showSuccessfulDialog(BuildContext context) {
  showDialog(
    context: context,
    // Typically, success dialogs are not dismissible by tapping outside
    barrierDismissible: false,
    builder: (BuildContext context) {
      return buildSuccessfulDialog(context);
    },
  );
}