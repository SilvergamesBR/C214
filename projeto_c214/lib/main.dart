import 'package:flutter/material.dart';
import 'package:projeto_c214/models/movie.dart';
import 'package:projeto_c214/services/movie_service.dart';
import 'package:projeto_c214/widgets/movie_card.dart';
import 'package:projeto_c214/widgets/search_field.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Rating App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
      ),
      home: const MyHomePage(title: 'Movie Rating App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> movies = [];
  bool isLoading = true;
  String? errorMessage;
  String currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies({String? searchQuery}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedMovies = await MovieService.getMovies(
        nameFilter: searchQuery,
      );
      setState(() {
        movies = fetchedMovies;
        isLoading = false;
        currentSearchQuery = searchQuery ?? '';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshMovies() async {
    await _loadMovies(
      searchQuery: currentSearchQuery.isEmpty ? null : currentSearchQuery,
    );
  }

  void _onSearch(String? query) {
    if (query == null) {
    } else if (query.trim().isEmpty) {
      _loadMovies();
    } else {
      _loadMovies(searchQuery: query.trim());
    }
  }

  Future<void> _showRatingDialog(Movie movie) async {
    double rating = 5.0;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Rate ${movie.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current Rating: ${movie.ratingAverage.toStringAsFixed(1)} (${movie.ratingCount} votes)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text('Your Rating: ${rating.toStringAsFixed(1)}'),
                  Slider(
                    value: rating,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    label: rating.toStringAsFixed(1),
                    onChanged: (double value) {
                      setDialogState(() {
                        rating = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _submitRating(movie, rating);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(Movie movie, double rating) async {
    try {
      await MovieService.rateMovie(movie.id!, rating);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully rated ${movie.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshMovies(); // Refresh to show updated rating
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rating movie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMovies,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchField(
              labelText: 'Search Movies',
              hintText: 'Enter movie name...',
              helperText: 'Search by movie name',
              onSearch: _onSearch,
            ),
          ),
          Expanded(child: _buildMoviesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add movie feature - TODO')),
          );
        },
        tooltip: 'Add Movie',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMoviesList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading movies',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshMovies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              currentSearchQuery.isEmpty
                  ? 'No movies found'
                  : 'No movies match your search',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (currentSearchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Search query: "$currentSearchQuery"',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadMovies(),
                child: const Text('Show All Movies'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMovies,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              movies.map((movie) {
                return SizedBox(
                  width: 250,
                  child: MovieCard(
                    movie: movie,
                    onTap: () => _showRatingDialog(movie),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
