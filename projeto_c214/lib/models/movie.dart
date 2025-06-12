class Movie {
  final String name;
  final int duration;
  final List<String> actors;
  final String director;
  final double rating;

  Movie({
    required this.name,
    required this.duration,
    required this.actors,
    required this.director,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      name: json['name'] as String,
      duration: json['duration'] as int,
      actors: List<String>.from(json['actors'] as List<dynamic>),
      director: json['director'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'duration': duration,
    'actors': actors,
    'director': director,
    'rating': rating,
  };

  @override
  String toString() {
    return 'Movie{name: $name, duration: ${duration}min, actors: $actors, director: $director, rating: $rating}';
  }
}
