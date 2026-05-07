class AppFeatureFlags {
  AppFeatureFlags._();

  // Keep this false for builds where anonymous posting should be disabled.
  static const bool enableAnonymousPosting = true;

  static bool shouldMaskIdentity(bool isAnonymous) {
    return enableAnonymousPosting && isAnonymous;
  }
}
