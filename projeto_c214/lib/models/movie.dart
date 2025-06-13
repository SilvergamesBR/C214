class Movie {
  final int? id;
  final String name;
  final int duration;
  final List<String> actors;
  final String director;
  final double ratingAverage;
  final int ratingCount;

  Movie({
    this.id,
    required this.name,
    required this.duration,
    required this.actors,
    required this.director,
    required this.ratingAverage,
    required this.ratingCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      actors: List<String>.from(json['actors'] ?? []),
      director: json['director'],
      ratingAverage: (json['rating_average'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'actors': actors,
      'director': director,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
    };
  }

  Movie copyWith({
    int? id,
    String? name,
    int? duration,
    List<String>? actors,
    String? director,
    double? ratingAverage,
    int? ratingCount,
  }) {
    return Movie(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      actors: actors ?? this.actors,
      director: director ?? this.director,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  @override
  String toString() {
    return 'Movie(id: $id, name: $name, duration: $duration, director: $director, rating: $ratingAverage)';
  }
}

class MovieCreate {
  final String name;
  final int duration;
  final List<String> actors;
  final String director;

  MovieCreate({
    required this.name,
    required this.duration,
    required this.actors,
    required this.director,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'actors': actors,
      'director': director,
    };
  }
}

class RatingRequest {
  final double rating;

  RatingRequest({required this.rating});

  Map<String, dynamic> toJson() {
    return {'rating': rating};
  }
}
