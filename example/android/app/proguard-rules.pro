#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

-dontwarn sun.reflect.**
-dontwarn java.beans.**
-dontwarn sun.nio.ch.**
-dontwarn sun.misc.**

-keep class com.esotericsoftware.** {*;}

-keep class java.beans.** { *; }
-keep class sun.reflect.** { *; }
-keep class sun.nio.ch.** { *; }

-keep class com.snappydb.** { *; }
-dontwarn com.snappydb.**

# If you don't use OkHttp as a dep and the following

-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn okhttp3.internal.platform.ConscryptPlatform
-dontwarn org.conscrypt.ConscryptHostnameVerifier