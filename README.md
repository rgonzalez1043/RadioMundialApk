# Radio Mundial 📻

Una aplicación de radio online moderna desarrollada en Flutter que permite escuchar estaciones de radio de todo el mundo en tiempo real.

## Características ✨

- 🎵 **Reproductor de audio en tiempo real** - Escucha estaciones de radio en vivo
- 🔍 **Búsqueda avanzada** - Encuentra estaciones por nombre, país o género
- 🌍 **Estaciones internacionales** - Acceso a miles de estaciones de radio mundiales
- ❤️ **Favoritos** - Guarda tus estaciones preferidas
- 🎨 **Interfaz moderna** - Diseño oscuro y elegante
- 📱 **Multiplataforma** - Compatible con Android, iOS, Web y Desktop

## Funcionalidades 🚀

### Pestañas principales:
1. **Popular** - Estaciones más escuchadas del mundo
2. **Buscar** - Búsqueda por texto y filtros por género
3. **Países** - Explora estaciones por país
4. **Favoritos** - Tus estaciones guardadas

### Controles del reproductor:
- ▶️ Play/Pause
- ⏹️ Stop
- 🔊 Control de volumen
- ❤️ Agregar/quitar de favoritos

## Instalación 🛠️

### Prerrequisitos
- Flutter SDK (versión 3.9.2 o superior)
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd radio_mundial_api
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## Dependencias principales 📦

- `just_audio: ^0.9.36` - Reproductor de audio para streams
- `http: ^1.1.0` - Cliente HTTP para APIs
- `provider: ^6.1.1` - Gestión de estado
- `cached_network_image: ^3.3.0` - Cache de imágenes
- `font_awesome_flutter: ^10.6.0` - Iconos
- `lottie: ^2.7.0` - Animaciones

## Arquitectura 🏗️

```
lib/
├── models/           # Modelos de datos
│   └── radio_station.dart
├── services/         # Servicios y APIs
│   ├── audio_service.dart
│   └── radio_api_service.dart
├── providers/        # Gestión de estado
│   └── radio_provider.dart
├── screens/          # Pantallas de la app
│   └── home_screen.dart
├── widgets/          # Widgets reutilizables
│   ├── player_widget.dart
│   ├── station_list_widget.dart
│   └── search_widget.dart
└── main.dart         # Punto de entrada
```

## API utilizada 🌐

La aplicación utiliza la **Radio Browser API** (https://www.radio-browser.info/) que proporciona:
- Acceso gratuito a miles de estaciones de radio
- Búsqueda por nombre, país, género
- Metadatos de las estaciones
- URLs de streaming en tiempo real

## Uso 📱

1. **Explorar estaciones populares**: Abre la app y ve las estaciones más populares
2. **Buscar estaciones**: Usa la pestaña "Buscar" para encontrar estaciones específicas
3. **Reproducir**: Toca cualquier estación para comenzar a escuchar
4. **Controlar reproducción**: Usa los controles del reproductor en la parte superior
5. **Agregar favoritos**: Toca el corazón para guardar estaciones
6. **Explorar por país**: Ve a la pestaña "Países" para explorar por ubicación

## Características técnicas 🔧

- **Arquitectura**: Provider pattern para gestión de estado
- **Audio streaming**: Soporte para MP3, AAC y otros formatos
- **Cache**: Imágenes cacheadas para mejor rendimiento
- **Responsive**: Interfaz adaptable a diferentes tamaños de pantalla
- **Error handling**: Manejo robusto de errores de red y audio

## Próximas mejoras 🚧

- [ ] Modo sleep timer
- [ ] Ecualizador
- [ ] Grabación de streams
- [ ] Compartir estaciones
- [ ] Tema claro/oscuro
- [ ] Notificaciones de reproducción
- [ ] Historial de reproducción

## Contribuir 🤝

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia 📄

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## Soporte 💬

Si tienes problemas o preguntas:
- Abre un issue en GitHub
- Revisa la documentación de Flutter
- Consulta la API de Radio Browser

---

**¡Disfruta escuchando radio de todo el mundo! 🎵🌍**
