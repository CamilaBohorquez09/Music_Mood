import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../providers/audio_player_service.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService favoritesService = FavoritesService();
  final AudioPlayerService audioService = AudioPlayerService();
  late Future<List<Song>> favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = favoritesService.getFavorites();
  }

  Future<void> _removeFavorite(Song song) async {
    final trackId = song.trackId;
    if (trackId == null) return;

    try {
      await favoritesService.removeFavorite(trackId);
      if (!mounted) return;
      setState(() {
        favoritesFuture = favoritesService.getFavorites();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo quitar el favorito: $error')),
      );
    }
  }

  @override
  void dispose() {
    audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis favoritos'),
        backgroundColor: const Color(0xFF18182B),
      ),
      body: FutureBuilder<List<Song>>(
        future: favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB47AFF)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No se pudieron cargar tus favoritos.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(
              child: Text('Aún no tienes canciones favoritas.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final song = favorites[index];

              return Card(
                color: const Color(0xFF1C1C30),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      song.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 60,
                          height: 60,
                          child: Icon(Icons.music_note),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    song.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${song.artist}\n${song.genre}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<PlayerState>(
                        stream: audioService.player.playerStateStream,
                        builder: (context, snapshot) {
                          final isCurrentSong =
                              audioService.currentUrl == song.previewUrl;
                          final isPlaying =
                              isCurrentSong &&
                              (snapshot.data?.playing ?? false);

                          return IconButton(
                            tooltip: isPlaying ? 'Pausar' : 'Reproducir',
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: const Color(0xFFB47AFF),
                              size: 32,
                            ),
                            onPressed: song.previewUrl == null
                                ? null
                                : () async {
                                    try {
                                      if (isPlaying) {
                                        await audioService.pause();
                                      } else {
                                        await audioService.play(
                                          song.previewUrl!,
                                        );
                                      }
                                    } catch (error) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error de reproducción: $error',
                                              ),
                                            ),
                                          );
                                    }
                                  },
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Quitar de favoritos',
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () => _removeFavorite(song),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
