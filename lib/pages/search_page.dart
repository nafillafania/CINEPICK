
import 'dart:async';
import 'package:flutter/material.dart';
import '../movie.dart';
import '../movie_service.dart';
import '../services/favorites_store.dart';
import '../widgets/common_states.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class SearchPage extends StatefulWidget {
  final FavoritesStore favorites;

  const SearchPage({super.key, required this.favorites});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MovieService _service = MovieService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  Future<List<Movie>>? _resultsFuture;
  bool _hasSearched = false;
  int? _selectedGenre;

  final List<Map<String, dynamic>> _genres = [
    {'id': 28, 'name': 'Action', 'icon': Icons.local_fire_department},
    {'id': 12, 'name': 'Adventure', 'icon': Icons.explore},
    {'id': 16, 'name': 'Animation', 'icon': Icons.animation},
    {'id': 35, 'name': 'Comedy', 'icon': Icons.mood},
    {'id': 18, 'name': 'Drama', 'icon': Icons.theater_comedy},
    {'id': 27, 'name': 'Horror', 'icon': Icons.nightlight},
    {'id': 10749, 'name': 'Romance', 'icon': Icons.favorite},
    {'id': 878, 'name': 'Sci-Fi', 'icon': Icons.rocket_launch},
    {'id': 53, 'name': 'Thriller', 'icon': Icons.bolt},
    {'id': 14, 'name': 'Fantasy', 'icon': Icons.auto_awesome},
    {'id': 80, 'name': 'Crime', 'icon': Icons.gavel},
    {'id': 99, 'name': 'Documentary', 'icon': Icons.movie},
  ];

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    setState(() {
      _selectedGenre = null;

      if (query.isEmpty) {
        _hasSearched = false;
        _resultsFuture = null;
      }
    });

    if (query.isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _hasSearched = true;
        _resultsFuture = _service.searchMovies(query);
      });
    });
  }

  void _selectGenre(int genreId) {
    FocusScope.of(context).unfocus();
    _controller.clear();
    _debounce?.cancel();

    setState(() {
      _selectedGenre = genreId;
      _hasSearched = true;
      _resultsFuture = _service.fetchMoviesByGenre(genreId);
    });
  }

  void _openDetails(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailPage(
          movie: movie,
          favorites: widget.favorites,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedGenreName = _genres.firstWhere(
      (genre) => genre['id'] == _selectedGenre,
      orElse: () => {'name': ''},
    )['name'] as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Film')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Masukkan judul film...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onQueryChanged('');
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF242130),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (!_hasSearched) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jelajahi Genre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Pilih genre sesuai suasana hatimu',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                ),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];

                  return Material(
                    color: const Color(0xFF242130),
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _selectGenre(genre['id'] as int),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              genre['icon'] as IconData,
                              color: const Color(0xFFD6A56D),
                              size: 26,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                genre['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedGenre == null
                          ? 'Hasil Pencarian'
                          : 'Genre: $selectedGenreName',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _controller.clear();
                      _onQueryChanged('');
                    },
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text('Genre'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: _resultsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return ErrorState(
                      message: 'Film gagal dimuat. Periksa koneksi internet.',
                      onRetry: () {
                        if (_selectedGenre != null) {
                          _selectGenre(_selectedGenre!);
                        } else {
                          _onQueryChanged(_controller.text);
                        }
                      },
                    );
                  }

                  final movies = snapshot.data ?? [];

                  if (movies.isEmpty) {
                    return const EmptyState(
                      title: 'Film tidak ditemukan',
                      message: 'Coba genre atau judul lainnya.',
                      icon: Icons.search_off_rounded,
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.57,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) => MovieCard(
                      movie: movies[index],
                      favorites: widget.favorites,
                      onTap: () => _openDetails(movies[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
