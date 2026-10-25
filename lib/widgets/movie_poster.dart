import 'package:flutter/material.dart';
import '../movie.dart';

class MoviePoster extends StatelessWidget {
  final Movie movie;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const MoviePoster({
    super.key,
    required this.movie,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final url = movie.posterUrl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url.isEmpty
            ? _placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF292438),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF292438),
        alignment: Alignment.center,
        child: const Icon(Icons.movie_outlined, color: Colors.white70, size: 36),
      );
}
