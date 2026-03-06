// ═══════════════════════════════════════════════════════════════
//  ForaTV - Favorites Service
//  Local storage for favorite movies, series, and channels
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _keyMovies = 'fav_movies';
  static const String _keySeries = 'fav_series';
  static const String _keyChannels = 'fav_channels';

  // ─── Movies ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getFavoriteMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyMovies);
    if (raw == null || raw.isEmpty) return [];
    return List<Map<String, dynamic>>.from(json.decode(raw));
  }

  static Future<void> addFavoriteMovie(Map<String, dynamic> movie) async {
    final list = await getFavoriteMovies();
    final id = movie['stream_id']?.toString() ?? '';
    if (list.any((m) => m['stream_id']?.toString() == id)) return;
    list.add(movie);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMovies, json.encode(list));
  }

  static Future<void> removeFavoriteMovie(String streamId) async {
    final list = await getFavoriteMovies();
    list.removeWhere((m) => m['stream_id']?.toString() == streamId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMovies, json.encode(list));
  }

  static Future<bool> isMovieFavorite(String streamId) async {
    final list = await getFavoriteMovies();
    return list.any((m) => m['stream_id']?.toString() == streamId);
  }

  // ─── Series ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getFavoriteSeries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySeries);
    if (raw == null || raw.isEmpty) return [];
    return List<Map<String, dynamic>>.from(json.decode(raw));
  }

  static Future<void> addFavoriteSeries(Map<String, dynamic> series) async {
    final list = await getFavoriteSeries();
    final id = series['series_id']?.toString() ?? '';
    if (list.any((s) => s['series_id']?.toString() == id)) return;
    list.add(series);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySeries, json.encode(list));
  }

  static Future<void> removeFavoriteSeries(String seriesId) async {
    final list = await getFavoriteSeries();
    list.removeWhere((s) => s['series_id']?.toString() == seriesId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySeries, json.encode(list));
  }

  static Future<bool> isSeriesFavorite(String seriesId) async {
    final list = await getFavoriteSeries();
    return list.any((s) => s['series_id']?.toString() == seriesId);
  }

  // ─── Channels ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getFavoriteChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyChannels);
    if (raw == null || raw.isEmpty) return [];
    return List<Map<String, dynamic>>.from(json.decode(raw));
  }

  static Future<void> addFavoriteChannel(Map<String, dynamic> channel) async {
    final list = await getFavoriteChannels();
    final id = channel['stream_id']?.toString() ?? '';
    if (list.any((c) => c['stream_id']?.toString() == id)) return;
    list.add(channel);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChannels, json.encode(list));
  }

  static Future<void> removeFavoriteChannel(String streamId) async {
    final list = await getFavoriteChannels();
    list.removeWhere((c) => c['stream_id']?.toString() == streamId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChannels, json.encode(list));
  }

  static Future<bool> isChannelFavorite(String streamId) async {
    final list = await getFavoriteChannels();
    return list.any((c) => c['stream_id']?.toString() == streamId);
  }
}
