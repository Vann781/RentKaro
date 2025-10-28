# flutter_local_notifications rules (Standard for background tasks)
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver

# Generic rule to protect native methods and JSON models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    @com.google.gson.annotations.Expose <fields>;
    @javax.inject.Inject <fields>;
    @javax.inject.Inject <init>();
}

# Protect specific Firebase classes if necessary (though usually handled by Google Services)
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }