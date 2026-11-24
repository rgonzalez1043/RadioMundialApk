package com.rgonzalez.worldradiofm

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity (del plugin audio_service) expone el FlutterEngine
// correcto para el audio en segundo plano y la notificación multimedia.
class MainActivity : AudioServiceActivity()
