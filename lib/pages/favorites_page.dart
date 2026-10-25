import 'package:flutter/material.dart';
import '../services/favorites_store.dart';
import '../widgets/common_states.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesStore favorites;
  const FavoritesPage({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Film Favorit')),
      body: AnimatedBuilder(
        animation: favorites,
        builder: (context, _) {
          if (!favorites.isLoaded) return const Center(child: CircularProgressIndicator());
          final movies = favorites.items;
          if (movies.isEmpty) return const EmptyState(title: 'Belum ada film favorit', message: 'Tekan ikon hati pada film untuk menyimpannya di sini.', icon: Icons.favorite_border_rounded);
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.57, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: movies.length,
            itemBuilder: (context, index) => MovieCard(
              movie: movies[index], favorites: favorites,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movies[index], favorites: favorites))),
            ),
          );
        },
      ),
    );
  }
}
