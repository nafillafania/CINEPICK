
import 'dart:async';
import 'package:flutter/material.dart';
import '../movie.dart';
import '../movie_service.dart';
import '../services/favorites_store.dart';
import '../widgets/common_states.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class HomePage extends StatefulWidget {
  final FavoritesStore favorites;
  final VoidCallback onExplore;

  const HomePage({
    super.key,
    required this.favorites,
    required this.onExplore,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovieService _service = MovieService();
  late Future<List<Movie>> _moviesFuture;

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _service.fetchPopularMovies();
  }

  void _startBanner(List<Movie> movies) {
    if (movies.length < 2 || _bannerTimer != null) return;

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!mounted || !_bannerController.hasClients) return;

        final nextIndex = (_bannerIndex + 1) % movies.length;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  void _retry() {
    _bannerTimer?.cancel();
    _bannerTimer = null;
    _bannerIndex = 0;

    setState(() {
      _moviesFuture = _service.fetchPopularMovies();
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
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _openMovieDetails(Movie movie) {
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

  Widget _buildBanner(List<Movie> movies) {
    final bannerMovies = movies
        .where((movie) => movie.backdropUrl.isNotEmpty)
        .take(8)
        .toList();

    if (bannerMovies.isEmpty) return const SizedBox.shrink();

    _startBanner(bannerMovies);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _bannerController,
                itemCount: bannerMovies.length,
                onPageChanged: (index) {
                  setState(() => _bannerIndex = index);
                },
                itemBuilder: (context, index) {
                  final movie = bannerMovies[index];
                  
                  return GestureDetector(
                    onTap: () => _openMovieDetails(movie),
                    child: Image.network(
                      movie.backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF292436),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.local_movies_rounded,
                          size: 48,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IgnorePointer(
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                       Colors.transparent,
                       Color(0xE6000000),
                      ],
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Temukan Film Favoritmu',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: widget.onExplore,
                        child: const Text('Jelajahi Film'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_bannerIndex + 1}/${bannerMovies.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.local_movies_rounded, color: cinePurple),
              SizedBox(width: 9),
              Text(
                'CinePick',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _retry,
              tooltip: 'Muat ulang',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder<List<Movie>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ErrorState(
                message: snapshot.error.toString(),
                onRetry: _retry,
              );
            }

            final movies = snapshot.data ?? [];

            if (movies.isEmpty) {
              return const EmptyState(
                title: 'Belum ada film',
                message: 'Coba muat ulang beberapa saat lagi.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _retry(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildBanner(movies),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(
                        'Film Populer',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.57,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final movie = movies[index];

                          return MovieCard(
                            movie: movie,
                            favorites: widget.favorites,
                            onTap: () => _openDetails(movie),
                          );
                        },
                        childCount: movies.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}
