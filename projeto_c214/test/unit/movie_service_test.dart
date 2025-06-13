import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:projeto_c214/models/movie.dart';
import 'package:projeto_c214/services/movie_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('MovieService', () {
    late MockHttpClient mockHttpClient;
    late MovieService movieService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      movieService = MovieService(httpClient: mockHttpClient);

      registerFallbackValue(Uri.parse('http://test.com'));
    });

    final sampleMovieJson = {
      'id': 1,
      'name': 'Test Movie',
      'duration': 120,
      'actors': ['Actor 1', 'Actor 2'],
      'director': 'Test Director',
      'rating_average': 8.5,
      'rating_count': 100,
    };

    final sampleMovieCreateJson = {
      'name': 'New Movie',
      'duration': 90,
      'actors': ['New Actor 1', 'New Actor 2'],
      'director': 'New Director',
    };

    final sampleMoviesListJson = [
      sampleMovieJson,
      {
        'id': 2,
        'name': 'Another Movie',
        'duration': 150,
        'actors': ['Actor 3', 'Actor 4'],
        'director': 'Another Director',
        'rating_average': 7.0,
        'rating_count': 50,
      },
    ];

    group('getMovies', () {
      test(
        'should return list of movies when API call is successful',
        () async {
          final response = http.Response(
            json.encode(sampleMoviesListJson),
            200,
          );
          when(
            () => mockHttpClient.get(
              Uri.parse('${MovieService.baseUrl}/movies/'),
              headers: MovieService.headers,
            ),
          ).thenAnswer((_) async => response);

          final result = await movieService.getMovies();

          expect(result, isA<List<Movie>>());
          expect(result.length, equals(2));
          expect(result[0].name, equals('Test Movie'));
          expect(result[1].name, equals('Another Movie'));

          verify(
            () => mockHttpClient.get(
              Uri.parse('${MovieService.baseUrl}/movies/'),
              headers: MovieService.headers,
            ),
          ).called(1);
        },
      );

      test('should include name filter in URL when provided', () async {
        const nameFilter = 'test movie';
        final response = http.Response(json.encode(sampleMoviesListJson), 200);
        when(
          () => mockHttpClient.get(
            Uri.parse(
              '${MovieService.baseUrl}/movies/?name=${Uri.encodeComponent(nameFilter)}',
            ),
            headers: MovieService.headers,
          ),
        ).thenAnswer((_) async => response);

        final result = await movieService.getMovies(nameFilter: nameFilter);

        expect(result, isA<List<Movie>>());
        verify(
          () => mockHttpClient.get(
            Uri.parse(
              '${MovieService.baseUrl}/movies/?name=${Uri.encodeComponent(nameFilter)}',
            ),
            headers: MovieService.headers,
          ),
        ).called(1);
      });

      test('should throw exception when API returns error status', () async {
        final response = http.Response('Server Error', 500);
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);

        expect(
          () => movieService.getMovies(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load movies: 500'),
            ),
          ),
        );
      });

      test('should throw exception when HTTP request fails', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenThrow(Exception('Network error'));

        expect(
          () => movieService.getMovies(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error fetching movies'),
            ),
          ),
        );
      });
    });

    group('getMovie', () {
      test('should return movie when API call is successful', () async {
        const movieId = 1;
        final response = http.Response(json.encode(sampleMovieJson), 200);
        when(
          () => mockHttpClient.get(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId'),
            headers: MovieService.headers,
          ),
        ).thenAnswer((_) async => response);

        final result = await movieService.getMovie(movieId);

        expect(result, isA<Movie>());
        expect(result.name, equals('Test Movie'));
        expect(result.id, equals(1));

        verify(
          () => mockHttpClient.get(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId'),
            headers: MovieService.headers,
          ),
        ).called(1);
      });

      test(
        'should throw "Movie not found" exception when API returns 404',
        () async {
          const movieId = 999;
          final response = http.Response('Not Found', 404);
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.getMovie(movieId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Movie not found'),
              ),
            ),
          );
        },
      );

      test(
        'should throw exception when API returns other error status',
        () async {
          const movieId = 1;
          final response = http.Response('Server Error', 500);
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.getMovie(movieId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to load movie: 500'),
              ),
            ),
          );
        },
      );
    });

    group('createMovie', () {
      test('should return created movie when API call is successful', () async {
        final movieCreate = MovieCreate.fromJson(sampleMovieCreateJson);
        final response = http.Response(json.encode(sampleMovieJson), 200);
        when(
          () => mockHttpClient.post(
            Uri.parse('${MovieService.baseUrl}/movies/'),
            headers: MovieService.headers,
            body: json.encode(movieCreate.toJson()),
          ),
        ).thenAnswer((_) async => response);

        final result = await movieService.createMovie(movieCreate);

        expect(result, isA<Movie>());
        expect(result.name, equals('Test Movie'));

        verify(
          () => mockHttpClient.post(
            Uri.parse('${MovieService.baseUrl}/movies/'),
            headers: MovieService.headers,
            body: json.encode(movieCreate.toJson()),
          ),
        ).called(1);
      });

      test('should throw exception when API returns error status', () async {
        final movieCreate = MovieCreate.fromJson(sampleMovieCreateJson);
        final response = http.Response('Bad Request', 400);
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => response);

        expect(
          () => movieService.createMovie(movieCreate),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to create movie: 400'),
            ),
          ),
        );
      });
    });

    group('rateMovie', () {
      test('should return updated movie when rating is successful', () async {
        const movieId = 1;
        const rating = 9.0;
        final updatedMovieJson = {...sampleMovieJson, 'rating_average': rating};
        final response = http.Response(json.encode(updatedMovieJson), 200);

        when(
          () => mockHttpClient.patch(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId/rating'),
            headers: MovieService.headers,
            body: json.encode({'rating': rating}),
          ),
        ).thenAnswer((_) async => response);

        final result = await movieService.rateMovie(movieId, rating);

        expect(result, isA<Movie>());
        expect(result.ratingAverage, equals(rating));

        verify(
          () => mockHttpClient.patch(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId/rating'),
            headers: MovieService.headers,
            body: json.encode({'rating': rating}),
          ),
        ).called(1);
      });

      test(
        'should throw "Movie not found" exception when API returns 404',
        () async {
          const movieId = 999;
          const rating = 8.0;
          final response = http.Response('Not Found', 404);
          when(
            () => mockHttpClient.patch(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.rateMovie(movieId, rating),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Movie not found'),
              ),
            ),
          );
        },
      );

      test(
        'should throw "Invalid rating" exception when API returns 400',
        () async {
          const movieId = 1;
          const rating = 15.0;
          final response = http.Response('Bad Request', 400);
          when(
            () => mockHttpClient.patch(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.rateMovie(movieId, rating),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Invalid rating. Must be between 0 and 10'),
              ),
            ),
          );
        },
      );
    });

    group('updateMovie', () {
      test('should return updated movie when API call is successful', () async {
        const movieId = 1;
        final movieCreate = MovieCreate.fromJson(sampleMovieCreateJson);
        final response = http.Response(json.encode(sampleMovieJson), 200);
        when(
          () => mockHttpClient.put(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId'),
            headers: MovieService.headers,
            body: json.encode(movieCreate.toJson()),
          ),
        ).thenAnswer((_) async => response);

        final result = await movieService.updateMovie(movieId, movieCreate);

        expect(result, isA<Movie>());
        expect(result.name, equals('Test Movie'));

        verify(
          () => mockHttpClient.put(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId'),
            headers: MovieService.headers,
            body: json.encode(movieCreate.toJson()),
          ),
        ).called(1);
      });

      test(
        'should throw "Movie not found" exception when API returns 404',
        () async {
          const movieId = 999;
          final movieCreate = MovieCreate.fromJson(sampleMovieCreateJson);
          final response = http.Response('Not Found', 404);
          when(
            () => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.updateMovie(movieId, movieCreate),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Movie not found'),
              ),
            ),
          );
        },
      );
    });

    group('deleteMovie', () {
      test('should complete successfully when API call returns 200', () async {
        const movieId = 1;
        final response = http.Response('', 200);
        when(
          () => mockHttpClient.delete(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId'),
            headers: MovieService.headers,
          ),
        ).thenAnswer((_) async => response);

        await movieService.deleteMovie(movieId);

        verify(
          () => mockHttpClient.delete(
            Uri.parse('${MovieService.baseUrl}/movies/$movieId'),
            headers: MovieService.headers,
          ),
        ).called(1);
      });

      test(
        'should throw "Movie not found" exception when API returns 404',
        () async {
          const movieId = 999;
          final response = http.Response('Not Found', 404);
          when(
            () => mockHttpClient.delete(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.deleteMovie(movieId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Movie not found'),
              ),
            ),
          );
        },
      );

      test(
        'should throw exception when API returns other error status',
        () async {
          const movieId = 1;
          final response = http.Response('Server Error', 500);
          when(
            () => mockHttpClient.delete(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => response);

          expect(
            () => movieService.deleteMovie(movieId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to delete movie: 500'),
              ),
            ),
          );
        },
      );
    });
  });
}
