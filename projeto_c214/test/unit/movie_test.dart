import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_c214/models/movie.dart';

void main() {
  group('Movie', () {
    group('constructor', () {
      test('should create Movie with all required fields', () {
        final movie = Movie(
          id: 1,
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1', 'Actor 2'],
          director: 'Test Director',
          ratingAverage: 8.5,
          ratingCount: 100,
        );

        expect(movie.id, equals(1));
        expect(movie.name, equals('Test Movie'));
        expect(movie.duration, equals(120));
        expect(movie.actors, equals(['Actor 1', 'Actor 2']));
        expect(movie.director, equals('Test Director'));
        expect(movie.ratingAverage, equals(8.5));
        expect(movie.ratingCount, equals(100));
      });

      test('should create Movie with null id', () {
        final movie = Movie(
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1'],
          director: 'Test Director',
          ratingAverage: 8.5,
          ratingCount: 100,
        );

        expect(movie.id, isNull);
        expect(movie.name, equals('Test Movie'));
      });
    });

    group('fromJson', () {
      test('should create Movie from complete JSON', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': ['Actor 1', 'Actor 2'],
          'director': 'Test Director',
          'rating_average': 8.5,
          'rating_count': 100,
        };

        final movie = Movie.fromJson(json);

        expect(movie.id, equals(1));
        expect(movie.name, equals('Test Movie'));
        expect(movie.duration, equals(120));
        expect(movie.actors, equals(['Actor 1', 'Actor 2']));
        expect(movie.director, equals('Test Director'));
        expect(movie.ratingAverage, equals(8.5));
        expect(movie.ratingCount, equals(100));
      });

      test('should handle null actors list', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': null,
          'director': 'Test Director',
          'rating_average': 8.5,
          'rating_count': 100,
        };

        final movie = Movie.fromJson(json);

        expect(movie.actors, equals([]));
      });

      test('should handle missing actors field', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'director': 'Test Director',
          'rating_average': 8.5,
          'rating_count': 100,
        };

        final movie = Movie.fromJson(json);

        expect(movie.actors, equals([]));
      });

      test('should handle null rating_average', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': ['Actor 1'],
          'director': 'Test Director',
          'rating_average': null,
          'rating_count': 100,
        };

        final movie = Movie.fromJson(json);

        expect(movie.ratingAverage, equals(0.0));
      });

      test('should handle missing rating_average field', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': ['Actor 1'],
          'director': 'Test Director',
          'rating_count': 100,
        };

        final movie = Movie.fromJson(json);

        expect(movie.ratingAverage, equals(0.0));
      });

      test('should handle null rating_count', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': ['Actor 1'],
          'director': 'Test Director',
          'rating_average': 8.5,
          'rating_count': null,
        };

        final movie = Movie.fromJson(json);

        expect(movie.ratingCount, equals(0));
      });

      test('should handle missing rating_count field', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': ['Actor 1'],
          'director': 'Test Director',
          'rating_average': 8.5,
        };

        final movie = Movie.fromJson(json);

        expect(movie.ratingCount, equals(0));
      });

      test('should convert int rating_average to double', () {
        const json = {
          'id': 1,
          'name': 'Test Movie',
          'duration': 120,
          'actors': ['Actor 1'],
          'director': 'Test Director',
          'rating_average': 8,
          'rating_count': 100,
        };

        final movie = Movie.fromJson(json);

        expect(movie.ratingAverage, equals(8.0));
        expect(movie.ratingAverage, isA<double>());
      });
    });

    group('toJson', () {
      test('should convert Movie to JSON', () {
        final movie = Movie(
          id: 1,
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1', 'Actor 2'],
          director: 'Test Director',
          ratingAverage: 8.5,
          ratingCount: 100,
        );

        final json = movie.toJson();

        expect(
          json,
          equals({
            'id': 1,
            'name': 'Test Movie',
            'duration': 120,
            'actors': ['Actor 1', 'Actor 2'],
            'director': 'Test Director',
            'rating_average': 8.5,
            'rating_count': 100,
          }),
        );
      });

      test('should handle null id in toJson', () {
        final movie = Movie(
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1'],
          director: 'Test Director',
          ratingAverage: 8.5,
          ratingCount: 100,
        );

        final json = movie.toJson();

        expect(json['id'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final originalMovie = Movie(
          id: 1,
          name: 'Original Movie',
          duration: 120,
          actors: ['Actor 1'],
          director: 'Original Director',
          ratingAverage: 8.0,
          ratingCount: 50,
        );

        final updatedMovie = originalMovie.copyWith(
          name: 'Updated Movie',
          ratingAverage: 9.0,
        );

        expect(updatedMovie.id, equals(1));
        expect(updatedMovie.name, equals('Updated Movie'));
        expect(updatedMovie.duration, equals(120));
        expect(updatedMovie.actors, equals(['Actor 1']));
        expect(updatedMovie.director, equals('Original Director'));
        expect(updatedMovie.ratingAverage, equals(9.0));
        expect(updatedMovie.ratingCount, equals(50));
      });

      test('should create exact copy when no parameters provided', () {
        final originalMovie = Movie(
          id: 1,
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1'],
          director: 'Test Director',
          ratingAverage: 8.0,
          ratingCount: 50,
        );

        final copiedMovie = originalMovie.copyWith();

        expect(copiedMovie.id, equals(originalMovie.id));
        expect(copiedMovie.name, equals(originalMovie.name));
        expect(copiedMovie.duration, equals(originalMovie.duration));
        expect(copiedMovie.actors, equals(originalMovie.actors));
        expect(copiedMovie.director, equals(originalMovie.director));
        expect(copiedMovie.ratingAverage, equals(originalMovie.ratingAverage));
        expect(copiedMovie.ratingCount, equals(originalMovie.ratingCount));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final movie = Movie(
          id: 1,
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1'],
          director: 'Test Director',
          ratingAverage: 8.5,
          ratingCount: 100,
        );

        final stringRepresentation = movie.toString();

        expect(
          stringRepresentation,
          equals(
            'Movie(id: 1, name: Test Movie, duration: 120, director: Test Director, rating: 8.5)',
          ),
        );
      });

      test('should handle null id in toString', () {
        final movie = Movie(
          name: 'Test Movie',
          duration: 120,
          actors: ['Actor 1'],
          director: 'Test Director',
          ratingAverage: 8.5,
          ratingCount: 100,
        );

        final stringRepresentation = movie.toString();

        expect(
          stringRepresentation,
          equals(
            'Movie(id: null, name: Test Movie, duration: 120, director: Test Director, rating: 8.5)',
          ),
        );
      });
    });
  });

  group('MovieCreate', () {
    group('constructor', () {
      test('should create MovieCreate with all required fields', () {
        final movieCreate = MovieCreate(
          name: 'New Movie',
          duration: 90,
          actors: ['New Actor 1', 'New Actor 2'],
          director: 'New Director',
        );

        expect(movieCreate.name, equals('New Movie'));
        expect(movieCreate.duration, equals(90));
        expect(movieCreate.actors, equals(['New Actor 1', 'New Actor 2']));
        expect(movieCreate.director, equals('New Director'));
      });
    });

    group('toJson', () {
      test('should convert MovieCreate to JSON', () {
        final movieCreate = MovieCreate(
          name: 'New Movie',
          duration: 90,
          actors: ['New Actor 1', 'New Actor 2'],
          director: 'New Director',
        );

        final json = movieCreate.toJson();

        expect(
          json,
          equals({
            'name': 'New Movie',
            'duration': 90,
            'actors': ['New Actor 1', 'New Actor 2'],
            'director': 'New Director',
          }),
        );
      });
    });

    group('fromJson', () {
      test('should create MovieCreate from complete JSON', () {
        const json = {
          'name': 'New Movie',
          'duration': 90,
          'actors': ['New Actor 1', 'New Actor 2'],
          'director': 'New Director',
        };

        final movieCreate = MovieCreate.fromJson(json);

        expect(movieCreate.name, equals('New Movie'));
        expect(movieCreate.duration, equals(90));
        expect(movieCreate.actors, equals(['New Actor 1', 'New Actor 2']));
        expect(movieCreate.director, equals('New Director'));
      });

      test('should handle null actors list', () {
        const json = {
          'name': 'New Movie',
          'duration': 90,
          'actors': null,
          'director': 'New Director',
        };

        final movieCreate = MovieCreate.fromJson(json);

        expect(movieCreate.actors, equals([]));
      });

      test('should handle missing actors field', () {
        const json = {
          'name': 'New Movie',
          'duration': 90,
          'director': 'New Director',
        };

        final movieCreate = MovieCreate.fromJson(json);

        expect(movieCreate.actors, equals([]));
      });
    });
  });

  group('RatingRequest', () {
    group('constructor', () {
      test('should create RatingRequest with rating', () {
        final ratingRequest = RatingRequest(rating: 9.5);

        expect(ratingRequest.rating, equals(9.5));
      });
    });

    group('toJson', () {
      test('should convert RatingRequest to JSON', () {
        final ratingRequest = RatingRequest(rating: 8.7);

        final json = ratingRequest.toJson();

        expect(json, equals({'rating': 8.7}));
      });
    });
  });
}
