import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mood_music/main.dart';
import 'package:mood_music/models/song.dart';
import 'package:mood_music/services/favorites_service.dart';

void main() {
  testWidgets('la pantalla principal muestra los estados de ánimo', (
    tester,
  ) async {
    await tester.pumpWidget(const MoodMusicApp());

    expect(find.text('¿Cómo te sientes hoy?'), findsOneWidget);
    expect(find.text('Feliz'), findsOneWidget);
    expect(find.byTooltip('Mis favoritos'), findsOneWidget);
  });

  test('los favoritos se guardan, no se duplican y se pueden quitar', () async {
    SharedPreferences.setMockInitialValues({});
    final service = FavoritesService();
    final song = Song(
      trackId: 123,
      name: 'Canción de prueba',
      artist: 'Artista de prueba',
      album: 'Álbum de prueba',
      imageUrl: 'https://example.com/artwork.jpg',
      previewUrl: 'https://example.com/preview.mp3',
      genre: 'Pop',
    );

    await service.addFavorite(song);
    await service.addFavorite(song);
    expect((await service.getFavorites()).map((item) => item.trackId), [123]);

    await service.removeFavorite(123);
    expect(await service.getFavorites(), isEmpty);
  });
}
