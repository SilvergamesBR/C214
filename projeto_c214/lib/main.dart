import 'package:flutter/material.dart';
import 'package:projeto_c214/models/mock_movies.dart';
import 'package:projeto_c214/widgets/movie_card.dart';
import 'package:projeto_c214/widgets/search_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SearchField(
            labelText: 'Pesquisar',
            hintText: 'Digite o que quer pesquisar',
            helperText: 'O resultado aparecerá na Snackbar',
            onSearch:
                (input) => {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Foi digitado $input na bara de pesquisa'),
                    ),
                  ),
                },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    mockMovies.map((movie) {
                      return SizedBox(
                        width: 250,
                        child: MovieCard(
                          movie: movie,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tapped on ${movie.name}'),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
