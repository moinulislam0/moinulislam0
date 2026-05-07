class ApiEndPoints {
  ApiEndPoints._();
  static const String baseUrl =
      'https://backend.silentwhistle.app';
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  static const String getBanners = '$baseUrl/api/getBanners';
  static const String getProducts = '$baseUrl/api/products';
  static const String getUsers = '$baseUrl/api/auth/me';
  static const String verifyOtp = '$baseUrl/api/auth/verify-email';
  static const String forgotPw = '$baseUrl/api/auth/forgot-password';
  static const String checkme = '$baseUrl/api/auth/me';
  static const String forgotVerify = '$baseUrl/api/auth/verify-email';
  static const String newPassword = '$baseUrl/api/auth/reset-password';
  static const String signUp = '$baseUrl/api/auth/register';
  static const String regisOtpVeri = '$baseUrl/api/auth/verify-email';
  static const String notification = '$baseUrl/api/notifications';
  static const String resendCode =
      '$baseUrl/api/auth/resend-verification-email';
  static const String shout = '$baseUrl/api/shout';
  static String like(String id) => '$baseUrl/api/shout/$id/like';
  static String unlike(String id) => '$baseUrl/api/shout/$id/like';

  static String getProfile(int pageNo, int pageSize, String userId) =>
      '$baseUrl/api/shout/user/$userId?page=$pageNo&limit=$pageSize';
  static String comment(String id) => '$baseUrl/api/shout/$id/comment';
  static String repcomment(String shoutId) => '$baseUrl/api/shout/$shoutId/comment';
  static String reportShout(String id) => '$baseUrl/api/shout/$id/report';

  static String postDelete(String id) => '$baseUrl/api/shout/$id';
  static const String profilePictureUpdate= '$baseUrl/api/auth/update';
  static String notifiDelete(String id) => '$baseUrl/api/notifications/$id/delete';

  //payment
  static const String startTrial = '$baseUrl/api/subscription/start-trial';
  static const String chargeCard = '$baseUrl/api/subscription/payment/charge';
  static const String getAllPlans = '$baseUrl/api/subscription/plans';
  static const String getSubscriptionStatus = '$baseUrl/api/subscription/status';
  static const String cancelSubscription = '$baseUrl/api/subscription/cancel';
  static const String subscriptionOtp = '$baseUrl/api/subscription/payment/otp';
  static const String verifySubscription = '$baseUrl/api/subscription/verify';

  ///map
  static const String mapSearch = '$baseUrl/api/map-explore/search';
  static const String mapSave = '$baseUrl/api/map-explore/save';
  static const String mapDetails = '$baseUrl/api/map-explore/saved';
  static String mapDelete(String id) => '$baseUrl/api/map-explore/saved/$id';
  static const String changepass  = '$baseUrl/api/auth/change-password';
  static const String reportUser = '$baseUrl/api/auth/report-user';
  static const String blockUserForMeOnly =
      '$baseUrl/api/auth/block-user-for-me-only';
  static const String myBlockedUsers = '$baseUrl/api/auth/my-blocked-users';
  static const String unblockUser = '$baseUrl/api/auth/unblock-user';


  //editProfile
    static const String editProfile = '$baseUrl/api/auth/update';
    static const String deleteAccount = '$baseUrl/api/auth/delete-account';
    static const String disableAccount = '$baseUrl/api/auth/disable-account';
    static const String enableAccount = '$baseUrl/api/auth/enable-account';
    static const String support = '$baseUrl/api/auth/ask-help-support';



  static String loadReply(String id) => '$baseUrl/api/shout/comment/$id/replies';
  static String share(String id) => '$baseUrl/api/shout/$id/share';
  static String likeComment(String parentId,String childrenId) => '$baseUrl/api/shout/$parentId/comment/$childrenId/like';
  static String unlikeComment(String parentId,String childrenId) => '$baseUrl/api/shout/$parentId/comment/$childrenId/unlike';
  static String editshout(String id) => '$baseUrl/api/shout/$id';
}
