# MoodMusic

MoodMusic es una aplicación Flutter para descubrir y reproducir fragmentos de canciones según el estado de ánimo. Permite guardar canciones favoritas en el dispositivo y volver a reproducirlas desde una lista dedicada.

## Funcionalidades

- **Música por estado de ánimo:** elige entre Feliz, Triste, Relajado y Energético. Cada estado selecciona al azar una búsqueda relacionada y consulta iTunes con ella.
- **Listas con variedad:** se solicitan hasta 50 resultados, se eliminan canciones duplicadas por identificador o URL de reproducción y se mezclan antes de mostrarlas. Al volver a entrar a un estado de ánimo, puede cambiar tanto la búsqueda como el orden de las recomendaciones.
- **Reproducción de fragmentos:** cada resultado incluye un botón para reproducir o pausar su vista previa, cuando iTunes ofrece una.
- **Favoritos:** toca el corazón de una canción para guardarla. El corazón relleno indica que está guardada; al tocarlo de nuevo se elimina.
- **Lista de favoritos:** abre el corazón de la pantalla principal para consultar, reproducir o quitar canciones favoritas.
- **Persistencia local:** los favoritos se guardan en el almacenamiento del dispositivo mediante `shared_preferences`; no hace falta crear una cuenta.

> La disponibilidad de canciones, imágenes y fragmentos depende de los resultados de la API de búsqueda de iTunes. La vista previa puede no estar disponible para todos los resultados y no equivale a reproducir la canción completa.

## Requisitos

- Flutter SDK instalado y disponible en el `PATH`.
- Dart SDK compatible con la versión indicada en `pubspec.yaml`.
- Conexión a Internet para consultar iTunes y cargar imágenes y vistas previas.
- Un emulador, simulador o dispositivo configurado para la plataforma que quieras ejecutar.

## Instalación y ejecución

Desde la raíz del proyecto:

```bash
flutter pub get
flutter run
```

Para seleccionar un dispositivo concreto:

```bash
flutter devices
flutter run -d <device-id>
```

## Verificación

Ejecuta el analizador estático y las pruebas con:

```bash
flutter analyze
flutter test
```

## Estructura del proyecto

```text
lib/
  main.dart                       Configuración y punto de entrada de la app
  models/song.dart                Modelo de canción y conversión JSON
  providers/audio_player_service.dart
                                  Reproducción de vistas previas con just_audio
  screens/home_screen.dart        Selección del estado de ánimo
  screens/songs_screen.dart       Resultados, reproducción y botón de favoritos
  screens/favorites_screen.dart   Lista local de favoritos
  services/music_service.dart     Consulta y selección de resultados de iTunes
  services/favorites_service.dart Lectura y escritura de favoritos
  widgets/                        Tarjetas reutilizables de la interfaz
test/
  widget_test.dart                Pruebas de widgets
```

## Tecnologías y servicios

- **Flutter / Dart:** interfaz y lógica de la aplicación.
- **iTunes Search API:** búsqueda de canciones y metadatos. No requiere una clave para las consultas que usa este proyecto.
- **just_audio:** reproducción de las URL de vista previa devueltas por iTunes.
- **shared_preferences:** almacenamiento local de favoritos en formato JSON.
- **http:** solicitudes a la API de iTunes.

## Cómo funciona el flujo principal

1. La pantalla principal ofrece cuatro estados de ánimo, cada uno vinculado a varios términos de búsqueda relacionados; al entrar se elige uno al azar.
2. `MusicService` consulta iTunes, convierte los resultados al modelo `Song`, descarta identificadores y vistas previas repetidos y mezcla los resultados.
3. `SongsScreen` presenta las canciones y permite reproducir las vistas previas o alternar su estado de favorito.
4. `FavoritesService` guarda y recupera las canciones en las preferencias locales del dispositivo.
5. `FavoritesScreen` carga los favoritos guardados, permite reproducirlos y quitarlos de la lista.

## Notas

- La mezcla ofrece un orden diferente de recomendaciones, pero el catálogo depende de los resultados que iTunes devuelva para cada término.
- Los favoritos permanecen en el mismo dispositivo y pueden perderse al borrar los datos de la aplicación o desinstalarla.
- Este proyecto no incluye autenticación, sincronización entre dispositivos ni reproducción de canciones completas.
