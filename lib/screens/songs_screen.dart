import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../providers/audio_player_service.dart';
import '../services/favorites_service.dart';
import '../services/music_service.dart';

class SongsScreen extends StatefulWidget {
  final String mood;
  final String searchTerm;

  const SongsScreen({super.key, required this.mood, required this.searchTerm});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final AudioPlayerService audioService = AudioPlayerService();
  final MusicService musicService = MusicService();
  final FavoritesService favoritesService = FavoritesService();
  final Set<int> favoriteTrackIds = {};
  final Set<int> updatingFavoriteIds = {};

  late Future<List<Song>> songsFuture;

  @override
  void initState() {
    super.initState();
    songsFuture = _loadSongs();
  }

  Future<List<Song>> _loadSongs() async {
    final songs = await musicService.searchSongs(widget.searchTerm);
    final favorites = await favoritesService.getFavorites();
    if (mounted) {
      setState(() {
        favoriteTrackIds.addAll(
          favorites.map((song) => song.trackId).whereType<int>(),
        );
      });
    }
    return songs;
  }

  Future<void> _toggleFavorite(Song song) async {
    final trackId = song.trackId;
    if (trackId == null || updatingFavoriteIds.contains(trackId)) {
      return;
    }

    final wasFavorite = favoriteTrackIds.contains(trackId);
    setState(() => updatingFavoriteIds.add(trackId));

    try {
      if (wasFavorite) {
        await favoritesService.removeFavorite(trackId);
      } else {
        await favoritesService.addFavorite(song);
      }

      if (!mounted) return;
      setState(() {
        if (wasFavorite) {
          favoriteTrackIds.remove(trackId);
        } else {
          favoriteTrackIds.add(trackId);
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el favorito: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => updatingFavoriteIds.remove(trackId));
      }
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
        title: Text('Música para ${widget.mood}'),
        backgroundColor: const Color(0xFF18182B),
      ),
      body: FutureBuilder<List<Song>>(
        future: songsFuture,
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
                  'No se pudieron cargar las canciones.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return const Center(child: Text('No se encontraron canciones.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final trackId = song.trackId;

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
                        tooltip: trackId == null
                            ? 'Canción no disponible para favoritos'
                            : favoriteTrackIds.contains(trackId)
                            ? 'Quitar de favoritos'
                            : 'Agregar a favoritos',
                        icon: Icon(
                          favoriteTrackIds.contains(trackId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favoriteTrackIds.contains(trackId)
                              ? Colors.pinkAccent
                              : Colors.white70,
                        ),
                        onPressed:
                            trackId == null ||
                                updatingFavoriteIds.contains(trackId)
                            ? null
                            : () => _toggleFavorite(song),
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
