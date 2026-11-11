import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/song.dart';

class MusicService {
  // Dirección principal de la API de iTunes
  static const String baseUrl = 'https://itunes.apple.com/search';

  // Buscar canciones según el término recibido
  Future<List<Song>> searchSongs(String searchTerm) async {
    // Construir la dirección de consulta
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {'term': searchTerm, 'entity': 'song', 'limit': '50'},
    );

    // Realizar la petición HTTP
    final response = await http.get(uri);

    // Comprobar si la petición fue exitosa
    if (response.statusCode == 200) {
      // Convertir la respuesta JSON en un objeto Dart
      final data = jsonDecode(response.body);

      // Obtener la lista de canciones
      final List results = data['results'];

      final songs = <Song>[];
      final trackIds = <int>{};
      final previewUrls = <String>{};

      for (final result in results) {
        final song = Song.fromJson(result);

        if (song.trackId != null && !trackIds.add(song.trackId!)) {
          continue;
        }

        final previewUrl = song.previewUrl;
        if (previewUrl != null &&
            previewUrl.isNotEmpty &&
            !previewUrls.add(previewUrl)) {
          continue;
        }

        songs.add(song);
      }

      songs.shuffle(Random());
      return songs;
    } else {
      throw Exception('Error al consultar la API: ${response.statusCode}');
    }
  }
}
