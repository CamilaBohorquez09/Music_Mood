import 'dart:math';

import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import '../widgets/mood_card.dart';
import 'songs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moods = [
      {
        'title': 'Feliz',
        'emoji': '😊',
        'description': 'Música para sonreír',
        'color': const Color(0xFFFFC857),
        'searches': ['happy pop', 'feel good pop', 'upbeat pop'],
      },
      {
        'title': 'Triste',
        'emoji': '😢',
        'description': 'Canciones para sentir',
        'color': const Color(0xFF9B5DE5),
        'searches': ['sad acoustic', 'melancholic indie', 'sad ballads'],
      },
      {
        'title': 'Relajado',
        'emoji': '😌',
        'description': 'Desconecta y disfruta',
        'color': const Color(0xFF43AA8B),
        'searches': ['relax instrumental', 'chill ambient', 'lo-fi chill'],
      },
      {
        'title': 'Energético',
        'emoji': '🔥',
        'description': 'Activa tu energía',
        'color': const Color(0xFFFF6B6B),
        'searches': ['energetic rock', 'workout rock', 'upbeat dance'],
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.graphic_eq,
                    color: Color(0xFFB47AFF),
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MoodMusic',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Mis favoritos',
                    icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                '¡Hola! 👋',
                style: TextStyle(fontSize: 17, color: Colors.white70),
              ),

              const SizedBox(height: 8),

              const Text(
                '¿Cómo te sientes hoy?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                'Selecciona tu estado de ánimo y encuentra '
                'la música perfecta para este momento.',
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),

              const SizedBox(height: 25),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final mood = moods[index];

                  return MoodCard(
                    title: mood['title'] as String,
                    emoji: mood['emoji'] as String,
                    description: mood['description'] as String,
                    color: mood['color'] as Color,
                    onTap: () {
                      final searches = mood['searches'] as List<String>;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongsScreen(
                            mood: mood['title'] as String,
                            searchTerm:
                                searches[Random().nextInt(searches.length)],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'Tu música, tu momento 🎧',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Descubre canciones que conecten contigo '
                'y disfruta cada momento.',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
