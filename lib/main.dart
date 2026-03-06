// ═══════════════════════════════════════════════════════════════
//  ForaTV - Main Entry Point
//  Firebase initialized + Provider state management + Theming
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/app_provider.dart';
import 'providers/download_provider.dart';
import 'utils/app_constants.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Status Bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase safely
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCATn7lwg2x5kxEkfrGpW4UbRlc7KpHEDg",
          authDomain: "upload-92830.firebaseapp.com",
          projectId: "upload-92830",
          storageBucket: "upload-92830.appspot.com",
          messagingSenderId: "100060804942",
          appId: "1:100060804942:web:3b7e88d9261d4cb6a4901f",
          measurementId: "G-1ZGTVPHKL1",
        ),
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized');
    } else {
      debugPrint('Firebase initialization error: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: const ForaTVApp(),
    ),
  );
}

class ForaTVApp extends StatelessWidget {
  const ForaTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<AppProvider>(
          builder: (context, provider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppConstants.appName,
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
