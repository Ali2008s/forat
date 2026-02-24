// ═══════════════════════════════════════════════════════════════
//  ForaTV - App Provider (State Management)
//  Central state management with Firebase real-time sync
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../services/xtream_service.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final XtreamService _xtream = XtreamService();

  // ─── State Variables ────────────────────────────────────────
  bool _isDarkMode = true;
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // App Status from Firebase
  bool _maintenanceMode = false;
  bool _appKilled = false;
  String _maintenanceMessage = '';
  String _notificationBar = '';
  bool _notificationEnabled = false;
  String _telegramLink = '';
  String _whatsappLink = '';

  // Update Info
  String _latestVersion = '';
  String _apkLink = '';
  String _updateNotes = '';
  bool _forceUpdate = false;
  bool _hasUpdate = false;

  // User Data
  String _username = '';
  String _password = '';
  String _clientName = '';
  String _serverHost = '';
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _subscriberData;

  // Xtream Data
  List<dynamic> _liveCategories = [];
  List<dynamic> _vodCategories = [];
  List<dynamic> _seriesCategories = [];

  // Listeners
  StreamSubscription? _appStatusSub;
  StreamSubscription? _updateInfoSub;
  StreamSubscription? _settingsSub;

  // ─── Getters ────────────────────────────────────────────────
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get maintenanceMode => _maintenanceMode;
  bool get appKilled => _appKilled;
  String get maintenanceMessage => _maintenanceMessage;
  String get notificationBar => _notificationBar;
  bool get notificationEnabled => _notificationEnabled;
  String get telegramLink => _telegramLink;
  String get whatsappLink => _whatsappLink;
  String get latestVersion => _latestVersion;
  String get apkLink => _apkLink;
  String get updateNotes => _updateNotes;
  bool get forceUpdate => _forceUpdate;
  bool get hasUpdate => _hasUpdate;
  String get username => _username;
  String get password => _password;
  String get clientName => _clientName;
  String get serverHost => _serverHost;
  Map<String, dynamic>? get userInfo => _userInfo;
  XtreamService get xtream => _xtream;
  List<dynamic> get liveCategories => _liveCategories;
  List<dynamic> get vodCategories => _vodCategories;
  List<dynamic> get seriesCategories => _seriesCategories;

  // ─── Firebase Initialization ────────────────────────────────
  bool _firebaseInitCalled = false;

  Future<void> initFirebase() async {
    if (_firebaseInitCalled) return;
    _firebaseInitCalled = true;

    // Listen to app status
    _appStatusSub = _firebase.appStatusStream.listen((snap) {
      if (snap.exists) {
        final d = snap.data() as Map<String, dynamic>? ?? {};
        _maintenanceMode = d['maintenance_mode'] ?? false;
        _appKilled = d['app_killed'] ?? false;
        _maintenanceMessage = d['maintenance_message'] ?? '';
        _notificationBar = d['notification_bar'] ?? '';
        notifyListeners();
      }
    });

    // Listen to update info
    _updateInfoSub = _firebase.updateInfoStream.listen((snap) {
      if (snap.exists) {
        final d = snap.data() as Map<String, dynamic>? ?? {};
        _latestVersion = d['version'] ?? '';
        _apkLink = d['apk_link'] ?? '';
        _updateNotes = d['notes'] ?? '';
        _forceUpdate = d['force_update'] ?? false;
        _checkForUpdate();
        notifyListeners();
      }
    });

    // Listen to settings
    _settingsSub = _firebase.settingsStream.listen((snap) {
      if (snap.exists) {
        final d = snap.data() as Map<String, dynamic>? ?? {};
        _telegramLink = d['telegram_link'] ?? '';
        _whatsappLink = d['whatsapp_link'] ?? '';
        _notificationEnabled = d['notification_enabled'] ?? false;
        notifyListeners();
      }
    });

    // Load saved credentials
    await _loadSavedCredentials();
    _isInitialized = true;
    notifyListeners();
  }

  void _checkForUpdate() {
    if (_latestVersion.isEmpty) {
      _hasUpdate = false;
      return;
    }
    _hasUpdate = _latestVersion != '1.0.0'; // Compare with current app version
  }

  // ─── Authentication ─────────────────────────────────────────
  Future<Map<String, dynamic>> login(
    String username,
    String password,
    String serverHost,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Verify in admin panel (Firebase)
      final subscriber = await _firebase.verifySubscriber(username, password);
      if (subscriber == null) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'error': 'بيانات الدخول غير صحيحة أو غير مسجلة في النظام',
        };
      }

      // Step 2: Check subscriber status
      if (!_firebase.isSubscriberValid(subscriber)) {
        _isLoading = false;
        notifyListeners();
        if (subscriber['status'] == 'blocked') {
          return {
            'success': false,
            'error': 'حسابك محظور. تواصل مع الدعم الفني',
          };
        }
        return {
          'success': false,
          'error': 'اشتراكك منتهي الصلاحية. يرجى التجديد',
        };
      }

      // Step 3: Authenticate with Xtream server
      _xtream.setCredentials(serverHost, username, password);
      final xtreamData = await _xtream.authenticate();
      if (xtreamData == null) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'error': 'فشل الاتصال بالسيرفر. تأكد من الرابط',
        };
      }

      // Success!
      _username = username;
      _password = password;
      _serverHost = serverHost;
      _clientName = subscriber['client_name'] ?? username;
      _userInfo = xtreamData['user_info'];
      _subscriberData = subscriber;
      _isLoggedIn = true;

      // Save credentials
      await _saveCredentials();

      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // ─── Categories Loading ─────────────────────────────────────
  Future<void> loadCategories() async {
    _liveCategories = await _xtream.getLiveCategories();
    _vodCategories = await _xtream.getVodCategories();
    _seriesCategories = await _xtream.getSeriesCategories();
    notifyListeners();
  }

  // ─── Credentials Persistence ────────────────────────────────
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setString('password', _password);
    await prefs.setString('server_host', _serverHost);
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('is_logged_in') ?? false;
    if (saved) {
      _username = prefs.getString('username') ?? '';
      _password = prefs.getString('password') ?? '';
      _serverHost = prefs.getString('server_host') ?? '';
      if (_username.isNotEmpty &&
          _password.isNotEmpty &&
          _serverHost.isNotEmpty) {
        _xtream.setCredentials(_serverHost, _username, _password);
      }
    }
  }

  Future<bool> tryAutoLogin() async {
    if (_username.isEmpty || _password.isEmpty || _serverHost.isEmpty)
      return false;
    final result = await login(_username, _password, _serverHost);
    return result['success'] == true;
  }

  // ─── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoggedIn = false;
    _username = '';
    _password = '';
    _serverHost = '';
    _userInfo = null;
    _subscriberData = null;
    _clientName = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // ─── Cleanup ────────────────────────────────────────────────
  @override
  void dispose() {
    _appStatusSub?.cancel();
    _updateInfoSub?.cancel();
    _settingsSub?.cancel();
    super.dispose();
  }
}
