# WorldRadio FM 📻

Una aplicación de radio online moderna desarrollada en Flutter que permite escuchar estaciones de radio de todo el mundo en tiempo real.

## Características ✨

- 🎵 **Reproductor de audio en tiempo real** - Escucha estaciones de radio en vivo
- 🔔 **Audio en segundo plano** - Notificación multimedia con controles en pantalla de bloqueo
- 📞 **Manejo de interrupciones** - Pausa automática con llamadas, alarmas y al desconectar auriculares
- 🔄 **Recuperación automática** - Si un stream no responde, avisa y prueba con la siguiente emisora; si la señal se corta, reconecta
- 😴 **Temporizador de apagado** - Duerme escuchando: apagado automático a los 5, 15, 30, 45 o 60 minutos
- 🚀 **Splash screen nativo** - Logo de WorldRadio FM al iniciar la app
- 🔍 **Búsqueda avanzada** - Encuentra estaciones por nombre, país o género
- 🌍 **Países dinámicos** - Más de 200 países con banderas, conteo de emisoras, filtro y lista de emisoras de cada país
- 🎸 **Géneros dinámicos** - Los géneros más populares de la API como filtros rápidos
- ❤️ **Favoritos** - Guarda tus estaciones preferidas (persisten entre sesiones)
- 🎨 **Interfaz moderna y responsiva** - Diseño oscuro elegante, adaptable a cualquier pantalla
- 📱 **Android** - Publicada en Google Play (`com.rgonzalez.worldradiofm`)

## Funcionalidades 🚀

### Pestañas principales:
1. **Popular** - Estaciones más escuchadas del mundo
2. **Buscar** - Búsqueda por texto y filtros rápidos por género
3. **Países** - Explora todos los países disponibles con buscador incluido
4. **Favoritos** - Tus estaciones guardadas

### Controles del reproductor:
- ▶️ Play/Pause
- ⏹️ Stop
- ❤️ Agregar/quitar de favoritos
- ⏲️ Temporizador de apagado (desde el AppBar)

## Instalación 🛠️

### Prerrequisitos
- Flutter SDK (versión 3.9.2 o superior)
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/rgonzalez1043/RadioMundialApk.git
   cd RadioMundialApk
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### Compilar para Google Play

La versión de release se firma con la llave de subida (*upload key*). Ni la llave ni sus contraseñas se suben a git:

- `android/key.properties` (ignorado por git) apunta al archivo `.jks` y guarda sus contraseñas.
- Sin `key.properties` la compilación usa la llave de depuración: sirve para probar, pero Play la rechaza.

```bash
# 1. Sube el número de versión en pubspec.yaml (p. ej. 1.0.1+2) antes de cada subida
# 2. Genera el App Bundle firmado
flutter build appbundle --release
# Resultado: build/app/outputs/bundle/release/app-release.aab
```

Los textos, gráficos y capturas de la ficha de Play Store están en [store/](store/), y la política de privacidad en [docs/](docs/) (publicada con GitHub Pages).

## Dependencias principales 📦

- `just_audio: ^0.10.6` - Reproductor de audio para streams en vivo
- `just_audio_background: ^0.0.1-beta.17` - Audio en segundo plano y notificación multimedia
- `audio_session: ^0.2.4` - Manejo del foco de audio e interrupciones
- `provider: ^6.1.1` - Gestión de estado
- `http: ^1.1.0` - Cliente HTTP para APIs
- `cached_network_image: ^3.3.0` - Cache de imágenes
- `font_awesome_flutter: ^10.6.0` - Iconos
- `shared_preferences: ^2.2.2` - Persistencia de favoritos
- `flutter_native_splash` (dev) - Generación del splash screen nativo

## Arquitectura 🏗️

```
lib/
├── models/           # Modelos de datos
│   ├── radio_station.dart
│   └── country.dart
├── services/         # Servicios y APIs
│   ├── audio_service.dart      # Reproductor (just_audio + sesión de audio)
│   └── radio_api_service.dart  # Cliente de Radio Browser API
├── providers/        # Gestión de estado
│   └── radio_provider.dart     # Estado, temporizador y recuperación de streams
├── screens/          # Pantallas de la app
│   └── home_screen.dart
├── widgets/          # Widgets reutilizables
│   ├── player_widget.dart
│   ├── station_list_widget.dart
│   └── search_widget.dart
└── main.dart         # Punto de entrada (inicializa audio en 2.º plano)
```

## API utilizada 🌐

La aplicación utiliza la **Radio Browser API** (https://www.radio-browser.info/) que proporciona:
- Acceso gratuito a miles de estaciones de radio
- Búsqueda por nombre, país, género
- Metadatos de las estaciones
- URLs de streaming en tiempo real

La app colabora con la comunidad registrando el clic de cada reproducción para las estadísticas de la API.

## Uso 📱

1. **Explorar estaciones populares**: Abre la app y ve las estaciones más populares
2. **Buscar estaciones**: Usa la pestaña "Buscar" o toca un género para filtrar
3. **Reproducir**: Toca cualquier estación para comenzar a escuchar
4. **Controlar reproducción**: Desde el reproductor en la app o la notificación multimedia
5. **Agregar favoritos**: Toca el corazón para guardar estaciones
6. **Explorar por país**: Ve a la pestaña "Países" y filtra por nombre
7. **Programar apagado**: Toca el cronómetro del AppBar y elige los minutos

## Características técnicas 🔧

- **Arquitectura**: Provider pattern para gestión de estado
- **Audio en segundo plano**: Servicio foreground con notificación multimedia (MediaSession)
- **Sesión de audio**: Pausa por foco perdido, interrupciones y auriculares desconectados
- **Recuperación de errores**: Reintento con estaciones alternativas y reconexión automática
- **Audio streaming**: Soporte para MP3, AAC y otros formatos
- **Cache**: Imágenes cacheadas para mejor rendimiento
- **Responsive**: Interfaz adaptable a diferentes tamaños de pantalla y escalado de fuente
- **Sin conexión**: mensajes claros con botón "Reintentar" (sin emisoras inventadas)
- **API robusta**: varios servidores espejo de Radio Browser, límite de tiempo por petición y emisoras caídas ocultas

## Próximas mejoras 🚧

- [ ] Ecualizador
- [ ] Grabación de streams
- [ ] Compartir estaciones
- [ ] Tema claro/oscuro
- [ ] Historial de reproducción
- [ ] Metadatos ICY (canción actual) en streams que los soporten

## Contribuir 🤝

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia 📄

Proyecto personal. Las transmisiones pertenecen a cada emisora; el directorio proviene de [Radio Browser](https://www.radio-browser.info/).

## Soporte 💬

Si tienes problemas o preguntas:
- Abre un issue en GitHub
- Revisa la documentación de Flutter
- Consulta la API de Radio Browser

---

**¡Disfruta escuchando radio de todo el mundo! 🎵🌍**
