
class Song {
  final int? trackId;
  final String name;
  final String artist;
  final String album;
  final String imageUrl;
  final String? previewUrl;
  final String genre;

  Song({
    this.trackId,
    required this.name,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.previewUrl,
    required this.genre,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      trackId: json['trackId'],
      name: json['trackName'] ?? 'Canción desconocida',
      artist: json['artistName'] ?? 'Artista desconocido',
      album: json['collectionName'] ?? 'Álbum desconocido',
      imageUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'],
      genre: json['primaryGenreName'] ?? 'Sin género',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': name,
      'artistName': artist,
      'collectionName': album,
      'artworkUrl100': imageUrl,
      'previewUrl': previewUrl,
      'primaryGenreName': genre,
    };
  }
}
