# Guía para publicar WorldRadio FM en Google Play

Cuenta: personal, creada después de noviembre de 2023. Antes de producción, Google exige una **prueba cerrada con al menos 12 testers durante 14 días seguidos**.

Datos fijos de la app:

| Dato | Valor |
|---|---|
| ID de la app (no se puede cambiar) | `com.rgonzalez.worldradiofm` |
| Versión | 1.0.0 (código 1) |
| Archivo a subir | `store/release/WorldRadioFM-1.0.0+1.aab` |
| Política de privacidad | https://rgonzalez1043.github.io/RadioMundialApk/privacy-policy.html |
| Correo de contacto | roberto10437@gmail.com |

---

## Paso 0: respaldar la llave de subida (hazlo hoy)

La app se firma con una *upload key*. La ruta del archivo `.jks` está en `android/key.properties`, en la línea `storeFile`, junto con su contraseña.

1. Copia el `.jks` y `key.properties` a un lugar seguro fuera de tu PC, por ejemplo un pendrive o un Drive privado.
2. No los subas nunca a GitHub. El `.gitignore` ya los excluye.

Si pierdes la llave, Google puede restablecerla: Play Console → Integridad de la app → Firma de apps → "Solicitar restablecimiento de la clave de subida". El trámite tarda varios días.

## Paso 1: publicar la política de privacidad (GitHub Pages)

1. En GitHub abre **RadioMundialApk → Settings → General**. En la sección *Danger Zone* elige **Change visibility → Make public**.
2. Ve a **Settings → Pages**. En *Build and deployment → Source* elige **Deploy from a branch**.
3. En *Branch* selecciona `main` y la carpeta `/docs`, y pulsa **Save**.
4. Espera 1 o 2 minutos y abre la URL de la política. Tiene que cargar la página "Política de privacidad de WorldRadio FM".

## Paso 2: revisar la cuenta de desarrollador

En [Play Console](https://play.google.com/console) → **Configuración → Detalles de la cuenta de desarrollador**:

- Verifica tu identidad, el correo y el teléfono de contacto si te los pide. Google cierra las cuentas inactivas que no tienen los datos de contacto verificados.
- Revisa el **nombre de desarrollador**. Es el nombre que verán los usuarios en la ficha.

Subir esta app (paso 6) ya cuenta como actividad en la cuenta.

## Paso 3: crear la app

**Inicio → Crear app**:

| Campo | Valor |
|---|---|
| Nombre de la app | `WorldRadio FM - Radio Online` |
| Idioma predeterminado | Español (Latinoamérica) – es-419 |
| App o juego | App |
| Gratis o pagada | Gratis (no se puede cambiar después) |
| Declaraciones | Acepta las Políticas del programa para desarrolladores y las leyes de exportación de EE. UU. |

## Paso 4: contenido de la app

Están en **Panel → "Configura tu app"** o en **Política → Contenido de la app**. Completa cada sección:

1. **Política de privacidad**: pega la URL del paso 1.
2. **Acceso a la app**: "Toda la funcionalidad está disponible sin restricciones de acceso".
3. **Anuncios**: "No, mi app no contiene anuncios".
4. **Clasificación de contenido** (cuestionario IARC):
   - Correo: el tuyo. Categoría: **Todas las demás apps** (*All other app types*), o **Entretenimiento** si aparece.
   - Responde con honestidad. La app no tiene violencia, contenido sexual, apuestas, compras ni chat entre usuarios.
   - Transmite radios de terceros en vivo, sin curar. Si te preguntan por lenguaje vulgar o contenido de terceros, lo prudente es responder **Sí**. La clasificación puede quedar en 12+ o en Teen, y eso es normal en apps de radio.
5. **Público objetivo**:
   - Marca **13–15, 16–17 y 18 o más**. No marques edades menores de 13: si lo haces, se aplica la política de Familias, que es mucho más exigente.
   - "¿La app podría atraer a niños?": **No**.
6. **App de noticias**: **No**. Incluye emisoras de noticias, pero no es una app de noticias.
7. **ID de publicidad**: "¿Usa ID de publicidad?" → **No**.
8. **Seguridad de los datos** (*Data safety*):
   - "¿Tu app recopila o comparte alguno de los tipos de datos de usuario requeridos?" → **No**.
   - Los favoritos se guardan solo en el teléfono. No hay cuentas, analítica ni anuncios.
   - Guarda y envía.
9. **Apps gubernamentales, funciones financieras y salud**: responde **No** en todas.
10. **Permisos de servicio en primer plano** (*Foreground service*): esta sección aparece después de subir el primer AAB.
    - Tipo: **Reproducción multimedia** (*Media playback*).
    - Video: sube [store/foreground-service-demo.mp4](foreground-service-demo.mp4) a YouTube como **Oculto** (*Unlisted*) y pega el enlace.
    - Descripción, lista para copiar:

    > WorldRadio FM es una app para escuchar radio por internet. El servicio en primer plano de tipo mediaPlayback se inicia solo cuando el usuario toca una emisora para reproducirla, y mantiene el audio sonando con la pantalla apagada o mientras usa otras apps. La notificación multimedia permite pausar o detener la radio. El servicio termina cuando el usuario detiene la reproducción.
    >
    > WorldRadio FM is an internet radio app. The mediaPlayback foreground service starts only when the user taps a station to play it, and keeps audio playing while the screen is off or the user is in another app. The media notification lets the user pause or stop playback. The service stops when the user stops playback.

    - Impacto si se interrumpe: "La radio dejaría de sonar al apagar la pantalla o cambiar de app".

## Paso 5: ficha de Play Store

Ve a **Crecimiento → Presencia en Play Store → Ficha principal**. Los textos están en [listing-es.md](listing-es.md).

| Campo | Archivo o texto |
|---|---|
| Nombre | `WorldRadio FM - Radio Online` |
| Descripción breve | Ver `listing-es.md` |
| Descripción completa | Ver `listing-es.md` |
| Ícono (512×512) | `store/icon-512.png` |
| Gráfico destacado (1024×500) | `store/feature-graphic-1024x500.png` |
| Capturas de teléfono | `store/screenshots/01` a `04` |

En **Configuración de la tienda**:

- Categoría: **Música y audio**.
- Correo: `roberto10437@gmail.com`.
- Sitio web (opcional): `https://rgonzalez1043.github.io/RadioMundialApk/`.

## Paso 6: prueba interna (opcional, pero recomendada)

Sirve para instalar la app desde Play en tu propio teléfono en minutos, sin esperar la revisión.

1. **Pruebas → Prueba interna → Crear versión**.
2. Acepta la **Firma de apps de Play**, que es la opción predeterminada.
3. Sube `WorldRadioFM-1.0.0+1.aab`. En las notas de la versión escribe: `Primera versión de WorldRadio FM.`
4. En **Testers** crea una lista con tu correo, guarda y copia el **enlace para unirse**.
5. Abre el enlace en tu teléfono, acepta la invitación e instala la app.
6. **Comprueba en tu teléfono el botón atrás del sistema**: atrás desde la lista de un país tiene que volver a la lista de países, y atrás desde la pantalla principal tiene que cerrar la app. En el emulador de Android 13 no funcionó ni con una app Flutter vacía, así que parece un problema de ese emulador. Igual hay que confirmarlo en un teléfono real.

## Paso 7: prueba cerrada con 12 testers durante 14 días (obligatoria)

1. **Pruebas → Prueba cerrada → Alpha → Administrar pista → Crear versión**. Sube el mismo AAB o pulsa "Promocionar versión" desde la prueba interna.
2. **Países y regiones**: agrega todos los países.
3. **Testers**: crea una lista de correo con **al menos 12 cuentas de Google**, o usa un Grupo de Google. Reúne más de 12 por si alguien se sale.
4. Envía la versión a revisión: **Publicación → Revisar cambios → Enviar a revisión**. La primera revisión puede tardar varios días.
5. Cuando la apruebe, comparte el **enlace para unirse**. Cada tester tiene que:
   - abrir el enlace con su cuenta de Google y pulsar **"Convertirse en tester"**;
   - instalar la app desde Play Store y usarla de vez en cuando;
   - **no salirse de la prueba** durante los 14 días.
6. El contador de 14 días empieza cuando hay 12 testers inscritos y corre de forma continua. Puedes verlo en el Panel.

Para conseguir testers puedes pedir ayuda a familiares, amigos o compañeros. También existen comunidades de intercambio de testers, donde tú pruebas sus apps y ellos la tuya. Google pregunta después cómo fue la prueba, así que conviene que los testers la usen de verdad y te dejen comentarios.

## Paso 8: solicitar acceso a producción

Después de 14 días con 12 o más testers:

1. Ve a **Panel → "Solicitar acceso a producción"**.
2. Responde el cuestionario: cómo reclutaste a los testers, qué te comentaron, qué mejoraste y por qué la app está lista. Contesta con detalle y con la verdad.
3. Google responde en unos 7 días, a veces menos.

## Paso 9: publicar en producción

1. **Producción → Crear versión**. Promociona el AAB de la prueba cerrada o sube uno nuevo; mira "Actualizaciones" más abajo.
2. **Países**: todos.
3. Notas de la versión: `Primera versión de WorldRadio FM: miles de radios en vivo de todo el mundo, favoritos y temporizador de apagado.`
4. **Revisar versión → Iniciar lanzamiento a producción**, al 100 %.
5. La revisión tarda entre horas y unos días. Cuando termine, la app queda **publicada** en `https://play.google.com/store/apps/details?id=com.rgonzalez.worldradiofm`.

## Actualizaciones (cada vez que cambies algo)

1. Sube la versión en `pubspec.yaml`. El número después del `+` tiene que ser siempre mayor que el anterior. Ejemplo: `version: 1.0.1+2`.
2. Ejecuta `flutter build appbundle --release`.
3. Sube `build/app/outputs/bundle/release/app-release.aab` a la pista que corresponda.

## Revisa también

- **Informe previo al lanzamiento** (*Pre-launch report*): Google instala la app en teléfonos reales y reporta fallos o problemas de accesibilidad. Revísalo después de cada subida.
- **Android Vitals**: muestra los fallos y bloqueos (ANR) de los usuarios reales.
