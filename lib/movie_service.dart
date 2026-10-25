import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';
import 'cast_member.dart';

class MovieService {
  static const String _apiKey = 'fa6bb71b11566a088273fe79bad7d386';

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String> params = const {},
  }) async {
    if (_apiKey.trim().isEmpty ||
        _apiKey == 'MASUKKAN_API_KEY_TMDB') {
      throw Exception(
        'Masukkan API key TMDB di movie_service.dart.',
      );
    }

    final query = <String, String>{
      'api_key': _apiKey,
      'language': 'id-ID',
      ...params,
    };

    final uri = Uri.https(
      'api.themoviedb.org',
      path,
      query,
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Permintaan TMDB gagal. '
        'Kode HTTP: ${response.statusCode}',
      );
    }

    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }

  List<Movie> _moviesFrom(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }

  Future<List<Movie>> fetchPopularMovies() async {
    final data = await _getJson(
      '/3/movie/popular',
      params: {'page': '1'},
    );

    return _moviesFrom(data);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final data = await _getJson(
      '/3/search/movie',
      params: {
        'query': query,
        'page': '1',
        'include_adult': 'false',
      },
    );

    return _moviesFrom(data);
  }

  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    final data = await _getJson(
      '/3/discover/movie',
      params: {
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
        'page': '1',
        'include_adult': 'false',
      },
    );

    return _moviesFrom(data);
  }

  Future<Movie> fetchMovieDetails(int movieId) async {
    // Ambil detail film dalam bahasa Indonesia terlebih dahulu.
    final dataId = await _getJson('/3/movie/$movieId');
    final overviewId =
        (dataId['overview'] as String? ?? '').trim();

    // Jika sinopsis Indonesia tersedia, gunakan sinopsis tersebut.
    if (overviewId.isNotEmpty) {
      return Movie.fromJson(dataId);
    }

    // Jika kosong, coba ambil sinopsis bahasa Inggris.
    try {
      final dataEn = await _getJson(
        '/3/movie/$movieId',
        params: {'language': 'en-US'},
      );

      final overviewEn =
          (dataEn['overview'] as String? ?? '').trim();

      if (overviewEn.isNotEmpty) {
        return Movie.fromJson({
          ...dataId,
          'overview': overviewEn,
        });
      }
    } catch (_) {
      // Jika pengambilan bahasa Inggris gagal,
      // gunakan pesan pengganti di bawah.
    }

    // Jika kedua bahasa tidak memiliki sinopsis.
    return Movie.fromJson({
      ...dataId,
      'overview': 'Sinopsis belum tersedia.',
    });
  }

  Future<String> fetchMovieOverview(int movieId) async {
    final movie = await fetchMovieDetails(movieId);
    return movie.overview;
  }

  Future<List<Movie>> fetchSimilarMovies(int movieId) async {
    final data = await _getJson(
      '/3/movie/$movieId/similar',
      params: {'page': '1'},
    );

    return _moviesFrom(data);
  }

  Future<List<CastMember>> fetchMovieCast(int movieId) async {
  final data = await _getJson('/3/movie/$movieId/credits');

  final cast = data['cast'] as List<dynamic>? ?? [];

  return cast
      .whereType<Map<String, dynamic>>()
      .map(CastMember.fromJson)
      .take(12)
      .toList();
  }
}
