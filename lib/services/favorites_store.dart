import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../movie.dart';

class FavoritesStore extends ChangeNotifier {
  static const String _storageKey = 'cinepick_favorites';
  final List<Movie> _items = [];
  bool _isLoaded = false;

  List<Movie> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;

  bool contains(int movieId) => _items.any((movie) => movie.id == movieId);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _items
          ..clear()
          ..addAll(decoded.whereType<Map<String, dynamic>>().map(Movie.fromStorage));
      }
    } catch (_) {
      // Jika data lokal rusak, aplikasi tetap dapat dibuka dengan daftar kosong.
      _items.clear();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggle(Movie movie) async {
    final index = _items.indexWhere((item) => item.id == movie.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.insert(0, movie);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_items.map((item) => item.toJson()).toList()),
    );
  }
}
