# This file contains ProGuard rules to prevent R8 from stripping classes
# required by Flutter plugins during the release build process.

# --- 1. CRITICAL: Protect Firebase Messaging and Core ---
# Protects all Firebase and FlutterFire plugin code from being stripped.
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# --- 2. CRITICAL: Flutter Local Notifications ---
-keep public class * extends android.app.Service {
    <init>(...);
}
-keep public class * extends android.content.BroadcastReceiver {
    <init>(...);
}
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- 3. Generic/Serialization Rules ---
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    @com.google.gson.annotations.Expose <fields>;
    @javax.inject.Inject <fields>;
    @javax.inject.Inject <init>();
}

# --- 4. Additional System Component Rules ---
-keep class android.support.v4.content.FileProvider { *; }
-keep public class com.example.rentkaro_frontend.MainActivity { *; }