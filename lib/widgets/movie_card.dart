import 'package:flutter/material.dart';
import '../movie.dart';
import '../services/favorites_store.dart';
import 'movie_poster.dart';

const Color cinePurple = Color(0xFF9B7BFF);
const Color cineBackground = Color(0xFF15131D);
const Color cineCard = Color(0xFF242130);

class MovieCard extends StatelessWidget {
  final Movie movie;
  final FavoritesStore favorites;
  final VoidCallback onTap;
  const MovieCard({super.key, required this.movie, required this.favorites, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFavorite = favorites.contains(movie.id);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: cineCard, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              MoviePoster(movie: movie),
              Positioned(
                top: 6, right: 6,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: const CircleBorder(),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                    onPressed: () async {
                      try { await favorites.toggle(movie); } catch (_) {}
                    },
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.pinkAccent : Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: 6, bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                    const SizedBox(width: 3),
                    Text(movie.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(movie.releaseDate.length >= 4 ? movie.releaseDate.substring(0, 4) : 'Tahun tidak tersedia',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ]),
      ),
    );
  }
}
