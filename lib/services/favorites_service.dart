
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class FavoritesService {
  static const String favoritesKey = 'favorite_songs';

  // Obtener todas las canciones favoritas
  Future<List<Song>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = prefs.getStringList(favoritesKey) ?? [];

    return favorites.map((song) {
      return Song.fromJson(jsonDecode(song));
    }).toList();
  }

  // Agregar una canción a favoritos
  Future<void> addFavorite(Song song) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    if (favorites.any((favorite) =>
        favorite.trackId == song.trackId)) {
      return;
    }

    favorites.add(song);

    final data = favorites.map((favorite) {
      return jsonEncode(favorite.toJson());
    }).toList();

    await prefs.setStringList(favoritesKey, data);
  }

  // Eliminar una canción de favoritos
  Future<void> removeFavorite(int trackId) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    favorites.removeWhere(
      (song) => song.trackId == trackId,
    );

    final data = favorites.map((song) {
      return jsonEncode(song.toJson());
    }).toList();

    await prefs.setStringList(favoritesKey, data);
  }

  // Comprobar si una canción es favorita
  Future<bool> isFavorite(int trackId) async {
    final favorites = await getFavorites();

    return favorites.any(
      (song) => song.trackId == trackId,
    );
  }
}
