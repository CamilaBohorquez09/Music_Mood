
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer player = AudioPlayer();

  String? currentUrl;

  // Reproducir un fragmento de audio
  Future<void> play(String url) async {
    try {
      currentUrl = url;

      await player.setUrl(url);
      await player.play();
    } catch (e) {
      throw Exception('No se pudo reproducir la canción: $e');
    }
  }

  // Pausar la reproducción
  Future<void> pause() async {
    await player.pause();
  }

  // Detener la reproducción
  Future<void> stop() async {
    await player.stop();
    currentUrl = null;
  }

  // Liberar los recursos del reproductor
  Future<void> dispose() async {
    await player.dispose();
  }
}
