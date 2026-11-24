class RadioStation {
  final String uuid;
  final String name;
  final String url;
  final String? favicon;
  final String? homepage;
  final String country;
  final String tags;
  final int votes;
  final int bitrate;
  final bool isPlaying;

  RadioStation({
    required this.uuid,
    required this.name,
    required this.url,
    this.favicon,
    this.homepage,
    required this.country,
    required this.tags,
    this.votes = 0,
    this.bitrate = 0,
    this.isPlaying = false,
  });

  // Getters para compatibilidad con el código existente
  String get id => uuid;
  String get streamUrl => url;
  String? get imageUrl => favicon;
  String? get description => homepage;
  String get genre => tags;

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString().trim() ?? '';
    int number(String key) {
      final value = json[key];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final resolved = str('url_resolved');
    final favicon = str('favicon');
    final homepage = str('homepage');
    final uuid = str('stationuuid');
    return RadioStation(
      uuid: uuid.isNotEmpty ? uuid : str('changeuuid'),
      name: str('name'),
      url: resolved.isNotEmpty ? resolved : str('url'),
      favicon: favicon.startsWith('http') ? favicon : null,
      homepage: homepage.isNotEmpty ? homepage : null,
      country: str('country'),
      tags: str('tags'),
      votes: number('votes'),
      bitrate: number('bitrate'),
    );
  }

  // Método para verificar si tiene un género específico
  bool hasGenre(String genre) {
    return tags.toLowerCase().contains(genre.toLowerCase());
  }

  Map<String, dynamic> toJson() {
    return {
      'stationuuid': uuid,
      'name': name,
      'url': url,
      'favicon': favicon,
      'homepage': homepage,
      'country': country,
      'tags': tags,
      'votes': votes,
      'bitrate': bitrate,
      'isPlaying': isPlaying,
    };
  }

  RadioStation copyWith({
    String? uuid,
    String? name,
    String? url,
    String? favicon,
    String? homepage,
    String? country,
    String? tags,
    int? votes,
    int? bitrate,
    bool? isPlaying,
  }) {
    return RadioStation(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      url: url ?? this.url,
      favicon: favicon ?? this.favicon,
      homepage: homepage ?? this.homepage,
      country: country ?? this.country,
      tags: tags ?? this.tags,
      votes: votes ?? this.votes,
      bitrate: bitrate ?? this.bitrate,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  String toString() {
    return 'RadioStation(id: $id, name: $name, country: $country, genre: $genre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadioStation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
