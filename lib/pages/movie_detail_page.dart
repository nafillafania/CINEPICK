import 'package:flutter/material.dart';
import '../movie.dart';
import '../movie_service.dart';
import '../services/favorites_store.dart';
import '../widgets/movie_poster.dart';
import '../widgets/movie_card.dart';
import '../cast_member.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final FavoritesStore favorites;
  const MovieDetailPage({super.key, required this.movie, required this.favorites});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MovieService _service = MovieService();
  late Future<Movie> _detailsFuture;
  late Future<List<Movie>> _similarFuture;
  late Future<List<CastMember>> _castFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _service.fetchMovieDetails(widget.movie.id);
    _similarFuture = _service.fetchSimilarMovies(widget.movie.id);
    _castFuture = _service.fetchMovieCast(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<Movie>(
          future: _detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError && !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Detail film gagal dimuat.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _detailsFuture =
                                _service.fetchMovieDetails(widget.movie.id);
                          });
                        },
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final movie = snapshot.data ?? widget.movie;
            return CustomScrollView(slivers: [

              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: cineBackground,
                actions: [
                  AnimatedBuilder(
                    animation: widget.favorites,
                    builder: (context, _) {
                      final isFavorite = widget.favorites.contains(movie.id);
                      return IconButton(
                        tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.pinkAccent : Colors.white),
                        onPressed: () async { try { await widget.favorites.toggle(movie); } catch (_) {} },
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  background: Stack(fit: StackFit.expand, children: [
                    movie.backdropUrl.isNotEmpty
                        ? Image.network(movie.backdropUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: cineCard))
                        : const ColoredBox(color: cineCard),
                    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, cineBackground], stops: [0.25, 1]))),
                  ]),
                ),
              ),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    MoviePoster(movie: movie, width: 112, height: 166),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(movie.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      _infoRow(Icons.star_rounded, movie.rating.toStringAsFixed(1), color: Colors.amber),
                      const SizedBox(height: 7),
                      _infoRow(Icons.calendar_month_outlined, movie.releaseDate == '-' ? 'Tanggal rilis tidak tersedia' : movie.releaseDate),
                      const SizedBox(height: 7),
                      _infoRow(Icons.schedule_rounded, movie.formattedRuntime),
                    ])),
                  ]),
                  if (movie.genres.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Wrap(spacing: 8, runSpacing: 8, children: movie.genres.map((genre) => Chip(label: Text(genre), backgroundColor: cineCard, side: BorderSide.none)).toList()),
                  ],
                  const SizedBox(height: 24),
                  const Text('Sinopsis', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(movie.overview, style: const TextStyle(height: 1.6, color: Colors.white70)),
                  const SizedBox(height: 24),
                  const Text('Pemeran', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,),),
                  const SizedBox(height: 12),

                  SizedBox(height: 210, child: FutureBuilder<List<CastMember>>( future: _castFuture, builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Data pemeran gagal dimuat.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final cast = snapshot.data ?? [];

                        if (cast.isEmpty) {
                          return const Center(
                            child: Text(
                              'Data pemeran belum tersedia.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cast.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final actor = cast[index];

                            return SizedBox(
                              width: 110,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: actor.profileUrl.isNotEmpty
                                        ? Image.network(
                                            actor.profileUrl,
                                            width: 110,
                                            height: 130,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 110,
                                                height: 130,
                                                color: Colors.white12,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.white70,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 110,
                                            height: 130,
                                            color: Colors.white12,
                                            child: const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.white70,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    actor.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    actor.character.isEmpty
                                        ? 'Karakter tidak tersedia'
                                        : actor.character,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  if (snapshot.connectionState == ConnectionState.waiting) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 28),
                  const Text('Film Serupa', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ]),
              )),
              SliverToBoxAdapter(child: SizedBox(
                height: 260,
                child: FutureBuilder<List<Movie>>(
                  future: _similarFuture,
                  builder: (context, similarSnapshot) {
                    if (similarSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (similarSnapshot.hasError) return const Padding(padding: EdgeInsets.all(16), child: Text('Film serupa belum dapat dimuat.', style: TextStyle(color: Colors.white60)));
                    final similar = (similarSnapshot.data ?? []).where((item) => item.id != movie.id).take(10).toList();
                    if (similar.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Belum ada rekomendasi film serupa.', style: TextStyle(color: Colors.white60)));
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: similar.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = similar[index];
                        return SizedBox(width: 145, child: MovieCard(movie: item, favorites: widget.favorites, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: item, favorites: widget.favorites)))));
                      },
                    );
                  },
                ),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ]);
          },
        ),
      );

  Widget _infoRow(IconData icon, String text, {Color color = Colors.white70}) => Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 7),
        Expanded(child: Text(text, style: TextStyle(color: color))),
      ]);
}
