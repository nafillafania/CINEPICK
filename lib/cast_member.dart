
class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(
    Map<String, dynamic> json,
  ) {
    return CastMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ??
          'Nama tidak tersedia',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  String get profileUrl {
    if (profilePath == null || profilePath!.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }
}
