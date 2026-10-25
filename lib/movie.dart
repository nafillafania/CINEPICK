class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double rating;
  final String releaseDate;
  final String? backdropPath;
  final int? runtime;
  final List<String> genres;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
    required this.releaseDate,
    this.backdropPath,
    this.runtime,
    this.genres = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'];
    final genres = rawGenres is List
        ? rawGenres.map((item) {
            if (item is Map) return item['name']?.toString() ?? '';
            return item.toString();
          }).where((name) => name.isNotEmpty).toList()
        : <String>[];

    final rawOverview = (json['overview'] as String? ?? '').trim();
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Judul tidak tersedia',
      overview: rawOverview.isNotEmpty ? rawOverview : 'Sinopsis belum tersedia.',
      posterPath: json['poster_path'] as String?,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '-',
      backdropPath: json['backdrop_path'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      genres: genres,
    );
  }

  factory Movie.fromStorage(Map<String, dynamic> json) => Movie.fromJson(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'vote_average': rating,
        'release_date': releaseDate,
        'backdrop_path': backdropPath,
        'runtime': runtime,
        'genres': genres,
      };

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get backdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) return posterUrl;
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }

  String get formattedRuntime {
    if (runtime == null || runtime! <= 0) return 'Durasi tidak tersedia';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours == 0) return '$minutes menit';
    if (minutes == 0) return '$hours jam';
    return '$hours jam $minutes menit';
  }
}
