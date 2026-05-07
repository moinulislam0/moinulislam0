# Add these specific rules for the missing SLF4J classes
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.impl.StaticMDCBinder
-dontwarn org.slf4j.impl.StaticMarkerBinder

# Keep the SLF4J API
-keep class org.slf4j.** { *; }

# This is the key - tell R8 these classes are provided at runtime
-dontnote org.slf4j.impl.**

# If the above doesn't work, use this nuclear option
-dontwarn org.slf4j.**

# OkHttp probes for optional TLS providers at runtime. These classes are
# intentionally absent unless the provider dependency is added, so suppress
# the release-shrinker warnings for those optional integrations.
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE