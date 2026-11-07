# R8 keeps Flutter's embedding and plugins; these rules protect reflection
# paths used by Firebase and the platform channels.
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
