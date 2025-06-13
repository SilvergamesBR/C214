import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  final http.Client _httpClient;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  MovieService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<List<Movie>> getMovies({String? nameFilter}) async {
    try {
      String url = '$baseUrl/movies/';
      if (nameFilter != null && nameFilter.isNotEmpty) {
        url += '?name=${Uri.encodeComponent(nameFilter)}';
      }

      final response = await _httpClient.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((movieJson) => Movie.fromJson(movieJson)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<Movie> getMovie(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/movies/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Movie.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else {
        throw Exception('Failed to load movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie: $e');
    }
  }

  Future<Movie> createMovie(MovieCreate movieCreate) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/movies/'),
        headers: headers,
        body: json.encode(movieCreate.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Movie.fromJson(jsonData);
      } else {
        throw Exception('Failed to create movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating movie: $e');
    }
  }

  Future<Movie> rateMovie(int movieId, double rating) async {
    try {
      final ratingRequest = {'rating': rating};
      final response = await _httpClient.patch(
        Uri.parse('$baseUrl/movies/$movieId/rating'),
        headers: headers,
        body: json.encode(ratingRequest),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Movie.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid rating. Must be between 0 and 10');
      } else {
        throw Exception('Failed to rate movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rating movie: $e');
    }
  }

  Future<Movie> updateMovie(int movieId, MovieCreate movieCreate) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/movies/$movieId'),
        headers: headers,
        body: json.encode(movieCreate.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Movie.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else {
        throw Exception('Failed to update movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating movie: $e');
    }
  }

  Future<void> deleteMovie(int movieId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/movies/$movieId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else {
        throw Exception('Failed to delete movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting movie: $e');
    }
  }
}
