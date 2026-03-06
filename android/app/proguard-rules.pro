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

# Play Core (Flutter Embedding) - Ignore missing classes
-dontwarn com.google.android.play.core.**

# General Flutter & Android rules
-keep class androidx.lifecycle.DefaultLifecycleObserver
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Add any other third-party library rules here if needed
