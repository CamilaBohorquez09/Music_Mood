import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioPlayerService {
  final AudioPlayer player = AudioPlayer();

  String? currentUrl;

  Future<void> play(String url) async {
    try {
      currentUrl = url;

      if(!kIsWeb||player.audioSource==null){
        await player.setUrl(url);
      }else{
        await player.clearAudioSources();
        await player.addAudioSource(AudioSource.uri(Uri.parse(url)));
        await player.load();
      }

      await player.setUrl(url);
      await player.play();

    } catch (e) {
      currentUrl=null;
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
