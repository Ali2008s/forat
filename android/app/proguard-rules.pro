# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# LibVLC rules
-keep class org.videolan.libvlc.** { *; }
-keep class org.videolan.vlc.** { *; }
-dontwarn org.videolan.libvlc.**
-dontwarn org.videolan.vlc.**

# Add any other third-party library rules here if needed
