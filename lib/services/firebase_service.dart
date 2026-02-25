// ═══════════════════════════════════════════════════════════════
//  ForaTV - Firebase Service
//  Handles all Firestore operations & real-time listeners
// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static FirebaseService? _instance;

  factory FirebaseService() => _instance ??= FirebaseService._();
  FirebaseService._();

  // ─── App Status ─────────────────────────────────────────────
  Stream<DocumentSnapshot> get appStatusStream => _db
      .collection(AppConstants.colConfig)
      .doc(AppConstants.docAppStatus)
      .snapshots();

  Future<Map<String, dynamic>?> getAppStatus() async {
    try {
      final doc = await _db
          .collection(AppConstants.colConfig)
          .doc(AppConstants.docAppStatus)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Error getting app status: $e');
      return null;
    }
  }

  // ─── Update Info ────────────────────────────────────────────
  Stream<DocumentSnapshot> get updateInfoStream => _db
      .collection(AppConstants.colConfig)
      .doc(AppConstants.docUpdateInfo)
      .snapshots();

  Future<Map<String, dynamic>?> getUpdateInfo() async {
    try {
      final doc = await _db
          .collection(AppConstants.colConfig)
          .doc(AppConstants.docUpdateInfo)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Error getting update info: $e');
      return null;
    }
  }

  // ─── Settings ───────────────────────────────────────────────
  Stream<DocumentSnapshot> get settingsStream => _db
      .collection(AppConstants.colConfig)
      .doc(AppConstants.docSettings)
      .snapshots();

  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final doc = await _db
          .collection(AppConstants.colConfig)
          .doc(AppConstants.docSettings)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Error getting settings: $e');
      return null;
    }
  }

  // ─── Servers ────────────────────────────────────────────────
  Stream<QuerySnapshot> get serversStream =>
      _db.collection(AppConstants.colServers).snapshots();

  Future<List<Map<String, dynamic>>> getActiveServers() async {
    try {
      final snap = await _db
          .collection(AppConstants.colServers)
          .where('status', isEqualTo: 'active')
          .get();
      return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('Error getting servers: $e');
      return [];
    }
  }

  // ─── Subscriber Verification ────────────────────────────────
  Future<Map<String, dynamic>?> verifySubscriber(
    String username,
    String password,
  ) async {
    try {
      final snap = await _db
          .collection(AppConstants.colSubscribers)
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return {'id': doc.id, ...doc.data()};
    } catch (e) {
      debugPrint('Error verifying subscriber: $e');
      return null;
    }
  }

  /// Check if subscriber is active and not expired
  bool isSubscriberValid(Map<String, dynamic> subscriber) {
    if (subscriber['status'] != 'active') return false;
    final expiry = subscriber['expiry_date'] as String?;
    if (expiry != null && expiry.isNotEmpty) {
      try {
        final expiryDate = DateTime.parse(expiry);
        if (expiryDate.isBefore(DateTime.now())) return false;
      } catch (_) {}
    }
    return true;
  }
}
