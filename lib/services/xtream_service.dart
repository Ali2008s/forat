// ═══════════════════════════════════════════════════════════════
//  ForaTV - Xtream API Service
//  Handles authentication & content fetching from Xtream Codes
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

List<dynamic> _parseList(String text) => jsonDecode(text) as List<dynamic>;
Map<String, dynamic>? _parseMap(String text) {
  final res = jsonDecode(text);
  if (res == null) return null;
  return res as Map<String, dynamic>;
}

class XtreamService {
  String _host = '';
  String _username = '';
  String _password = '';

  void setCredentials(String host, String username, String password) {
    _host = host.endsWith('/') ? host.substring(0, host.length - 1) : host;
    _username = username;
    _password = password;
  }

  String get baseUrl =>
      '$_host/player_api.php?username=$_username&password=$_password';
  String get host => _host;
  String get username => _username;
  String get password => _password;

  // ─── Authentication ─────────────────────────────────────────
  Future<Map<String, dynamic>?> authenticate() async {
    try {
      final url = baseUrl;
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user_info'] != null && data['user_info']['auth'] == 1) {
          return data;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Xtream auth error: $e');
      return null;
    }
  }

  // ─── Live TV ────────────────────────────────────────────────
  Future<List<dynamic>> getLiveCategories() async {
    try {
      final url = '$baseUrl&action=get_live_categories';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await compute(_parseList, response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting live categories: $e');
      return [];
    }
  }

  Future<List<dynamic>> getLiveStreams([String? categoryId]) async {
    try {
      String url = '$baseUrl&action=get_live_streams';
      if (categoryId != null) url += '&category_id=$categoryId';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return await compute(_parseList, response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting live streams: $e');
      return [];
    }
  }

  // ─── Movies (VOD) ──────────────────────────────────────────
  Future<List<dynamic>> getVodCategories() async {
    try {
      final url = '$baseUrl&action=get_vod_categories';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await compute(_parseList, response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting VOD categories: $e');
      return [];
    }
  }

  Future<List<dynamic>> getVodStreams([String? categoryId]) async {
    try {
      String url = '$baseUrl&action=get_vod_streams';
      if (categoryId != null) url += '&category_id=$categoryId';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return await compute(_parseList, response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting VOD streams: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVodInfo(String vodId) async {
    try {
      final url = '$baseUrl&action=get_vod_info&vod_id=$vodId';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await compute(_parseMap, response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting VOD info: $e');
      return null;
    }
  }

  // ─── Series ─────────────────────────────────────────────────
  Future<List<dynamic>> getSeriesCategories() async {
    try {
      final url = '$baseUrl&action=get_series_categories';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await compute(_parseList, response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting series categories: $e');
      return [];
    }
  }

  Future<List<dynamic>> getSeries([String? categoryId]) async {
    try {
      String url = '$baseUrl&action=get_series';
      if (categoryId != null) url += '&category_id=$categoryId';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return await compute(_parseList, response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting series: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSeriesInfo(String seriesId) async {
    try {
      final url = '$baseUrl&action=get_series_info&series_id=$seriesId';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await compute(_parseMap, response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting series info: $e');
      return null;
    }
  }

  // ─── Stream URLs ────────────────────────────────────────────
  String getLiveStreamUrl(String streamId, [String extension = 'ts']) {
    return '$_host/live/$_username/$_password/$streamId.$extension';
  }

  String getVodStreamUrl(String streamId, [String extension = 'mp4']) {
    return '$_host/movie/$_username/$_password/$streamId.$extension';
  }

  String getSeriesStreamUrl(String streamId, [String extension = 'mp4']) {
    return '$_host/series/$_username/$_password/$streamId.$extension';
  }
}
