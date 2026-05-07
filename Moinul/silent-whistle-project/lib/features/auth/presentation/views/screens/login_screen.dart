import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/core/services/local_storage_service/location_storage.dart';
import 'package:provider/provider.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/core/constant/route_names.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../model_view/login_screen_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryGreen = Color.fromARGB(255, 68, 239, 137);
  static const Color fieldBackground = Color.fromARGB(255, 10, 10, 10);
  static const MethodChannel _googleAuthChannel = MethodChannel(
    'jwells/google_auth',
  );
  static const String _googleServerClientIdFallback =
      '1092728584712-1sqns4e63p8p77qkskaqemct61s27ks0.apps.googleusercontent.com';
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
  

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(20.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Social Login Methods ---

  Future<void> _handleGoogleSignIn(LoginScreenProvider provider) async {
    try {
      final String resolvedServerClientId = await _resolveGoogleServerClientId();
      debugPrint('Google Sign-In started');
      debugPrint(
        'Google server client id configured: ${resolvedServerClientId.isNotEmpty}',
      );
      debugPrint(
        'Google server client id preview: ${_tokenPreview(resolvedServerClientId)}',
      );
      debugPrint('Google server client id raw: $resolvedServerClientId');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: resolvedServerClientId.isNotEmpty
            ? resolvedServerClientId
            : null,
      );

      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        return;
      }

      debugPrint('Google user email: ${googleUser.email}');
      debugPrint('Google user displayName: ${googleUser.displayName}');
      debugPrint('Google user id: ${googleUser.id}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      debugPrint('Google accessToken null: ${accessToken == null}');
      debugPrint('Google idToken null: ${idToken == null}');
      debugPrint('Google accessToken preview: ${_tokenPreview(accessToken)}');
      debugPrint('Google idToken preview: ${_tokenPreview(idToken)}');
      debugPrint('Google idToken raw: $idToken');

      if (idToken == null) {
        debugPrint(
          'Google Sign-In failed details: idToken is null, accessToken is ${accessToken == null ? "also null" : "available"}',
        );
        final message = resolvedServerClientId.isEmpty
            ? 'Failed to get ID token from Google. Firebase config still has no Web client ID. Download the latest google-services.json after enabling Google Sign-In and adding OAuth clients.'
            : 'Failed to get ID token from Google. Check Firebase Google Sign-In and OAuth client configuration.';
        debugPrint(message);
        _showErrorSnackBar(message);
        return;
      }

      final LocationStorage locationStorage = LocationStorage();
      final double latitude = await locationStorage.getLatitude() ?? 0.0;
      final double longitude = await locationStorage.getLongitude() ?? 0.0;

      final googleData = {
        "idToken": idToken,
        "latitude": latitude,
        "longitude": longitude,
      };
      debugPrint('Google social payload keys: ${googleData.keys.toList()}');

      await provider.socialLogin(type: 'google', data: googleData);

      if (!mounted) return;
      _handleAuthResponse(provider);
    } on PlatformException catch (e, stackTrace) {
      debugPrint('Google Sign-In PlatformException code: ${e.code}');
      debugPrint('Google Sign-In PlatformException message: ${e.message}');
      debugPrint('Google Sign-In PlatformException details: ${e.details}');
      debugPrint('Google Sign-In PlatformException stackTrace: $stackTrace');
      _showErrorSnackBar("Google Sign-In failed: ${e.message ?? e.code}");
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In unexpected error: $e');
      debugPrint('Google Sign-In unexpected stackTrace: $stackTrace');
      _showErrorSnackBar("Google Sign-In failed: $e");
    }
  }

  String _tokenPreview(String? token) {
    if (token == null || token.isEmpty) {
      return 'null';
    }
    if (token.length <= 24) {
      return token;
    }
    return '${token.substring(0, 12)}...${token.substring(token.length - 12)}';
  }

  Future<String> _resolveGoogleServerClientId() async {
    if (_googleServerClientId.isNotEmpty) {
      return _googleServerClientId;
    }

    try {
      final String? clientId = await _googleAuthChannel.invokeMethod<String>(
        'getDefaultWebClientId',
      );
      final String resolvedClientId = clientId?.trim() ?? '';
      if (resolvedClientId.isNotEmpty) {
        return resolvedClientId;
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to read default_web_client_id: ${e.message}');
    }
    debugPrint('Using fallback Google Web client ID');
    return _googleServerClientIdFallback;
  }

  Future<void> _handleAppleSignIn(LoginScreenProvider provider) async {
    try {
      debugPrint('========== Apple Sign-In Debug Start ==========');
      debugPrint('Apple Sign-In started');
      debugPrint('Platform is iOS: ${!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS}');
      debugPrint('Platform is Android: ${!kIsWeb && defaultTargetPlatform == TargetPlatform.android}');
      debugPrint('Is web platform: $kIsWeb');
      debugPrint(
        'Apple native credential request started without clientId/redirectUri.',
      );

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint('Apple userIdentifier: ${credential.userIdentifier}');
      debugPrint('Apple email: ${credential.email}');
      debugPrint('Apple givenName: ${credential.givenName}');
      debugPrint('Apple familyName: ${credential.familyName}');
      debugPrint(
        'Apple identityToken null: ${credential.identityToken == null || credential.identityToken!.isEmpty}',
      );
      debugPrint(
        'Apple authorizationCode null: ${credential.authorizationCode.isEmpty}',
      );
      debugPrint(
        'Apple identityToken preview: ${_tokenPreview(credential.identityToken)}',
      );
      debugPrint(
        'Apple authorizationCode preview: ${_tokenPreview(credential.authorizationCode)}',
      );

      final LocationStorage locationStorage = LocationStorage();
      final double latitude = await locationStorage.getLatitude() ?? 0.0;
      final double longitude = await locationStorage.getLongitude() ?? 0.0;
      debugPrint('Apple saved latitude: $latitude');
      debugPrint('Apple saved longitude: $longitude');

      final appleData = {
        "identityToken": credential.identityToken ?? "",
        "email": credential.email ?? "",
        "firstName": credential.givenName ?? "",
        "lastName": credential.familyName ?? "",
        "latitude": latitude,
        "longitude": longitude,
      };

      debugPrint('Apple social payload keys: ${appleData.keys.toList()}');
      debugPrint('Apple social payload: $appleData');

      await provider.socialLogin(type: 'apple', data: appleData);
      debugPrint('Apple socialLogin errorMessage: ${provider.errorMessage}');
      debugPrint('Apple socialLogin loading complete');
      debugPrint('========== Apple Sign-In Debug End ==========');

      if (!mounted) return;
      _handleAuthResponse(provider);
    } on PlatformException catch (e, stackTrace) {
      debugPrint('========== Apple Sign-In Debug Failed ==========');
      debugPrint('Apple Sign-In PlatformException code: ${e.code}');
      debugPrint('Apple Sign-In PlatformException message: ${e.message}');
      debugPrint('Apple Sign-In PlatformException details: ${e.details}');
      debugPrint('Apple Sign-In PlatformException stackTrace: $stackTrace');
      _showErrorSnackBar("Apple Sign-In failed: ${e.message ?? e.code}");
    } catch (e, stackTrace) {
      debugPrint('========== Apple Sign-In Debug Failed ==========');
      debugPrint('Apple Sign-In unexpected error: $e');
      debugPrint('Apple Sign-In unexpected stackTrace: $stackTrace');
      _showErrorSnackBar("Apple Sign-In failed: $e");
    }
  }

  void _handleAuthResponse(LoginScreenProvider provider) {
    if (provider.errorMessage == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.parentScreen,
        (route) => false,
      );
    } else {
      _showErrorSnackBar(provider.errorMessage!);
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login to your Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please enter your email & password to sign in.',
                      style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                    ),
                    SizedBox(height: 30.h),
                    _buildTextFormField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    _buildPasswordFormField(
                      controller: _passwordController,
                      hintText: 'Password',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, RouteNames.forgotPasswordScreen),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: primaryGreen, fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Consumer<LoginScreenProvider>(
                      builder: (context, provider, child) {
                        return PrimaryButton(
                          title: provider.isLoading ? "Logging in..." : "Log In",
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              await provider.userLogin(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                              if (!mounted) return;
                              _handleAuthResponse(provider);
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
                    _buildSignUpLink(),
                  ],
                ),
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
          colors: [Color(0xFF003200), Color(0xFF004600)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/logo.png',
            width: 60.w,
            height: 60.h,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.security, color: primaryGreen, size: 50.sp),
          ),
          SizedBox(height: 12.h),
          Text('Silent Whistle', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22.sp),
        filled: true,
        fillColor: fieldBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
      ),
    );
  }

  Widget _buildPasswordFormField({required TextEditingController controller, required String hintText}) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 22.sp),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey.shade600),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: fieldBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Consumer<LoginScreenProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous always-visible social auth buttons kept here for reference.
            // _buildSocialButton(
            //   icon: "assets/icons/google.png",
            //   onPressed: () => _handleGoogleSignIn(provider),
            // ),
            // SizedBox(width: 25.w),
            // _buildSocialButton(
            //   icon: "assets/icons/apple.png",
            //   onPressed: () => _handleAppleSignIn(provider),
            // ),
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              _buildSocialButton(
                icon: "assets/icons/google.png",
                onPressed: () => _handleGoogleSignIn(provider),
              ),
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
              _buildSocialButton(
                icon: "assets/icons/apple.png",
                onPressed: () => _handleAppleSignIn(provider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSocialButton({required String icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: fieldBackground,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.grey.shade900),
        ),
        child: Image.asset(icon,),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account? ", style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.signUpScreen),
            child: Text('Sign Up', style: TextStyle(color: primaryGreen, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
