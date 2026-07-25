class Country {
  final String name;
  final String iso31661;
  final int stationcount;

  Country({
    required this.name,
    required this.iso31661,
    required this.stationcount,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] ?? '',
      iso31661: json['iso_3166_1'] ?? '',
      stationcount: json['stationcount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iso_3166_1': iso31661,
      'stationcount': stationcount,
    };
  }

  @override
  String toString() {
    return 'Country(name: $name, code: $iso31661, stations: $stationcount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.iso31661 == iso31661;
  }

  @override
  int get hashCode => iso31661.hashCode;
}
