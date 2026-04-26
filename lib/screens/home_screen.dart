import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/article.dart';
import '../services/api_error_message.dart';
import '../services/news_api_service.dart';
import 'article_tile.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApiService _service = NewsApiService();
  NewsCountry _selectedCountry = _countries.first;
  late Future<List<Article>> _headlinesFuture;

  @override
  void initState() {
    super.initState();
    _headlinesFuture = _fetchSelectedCountryNews();
  }

  void _loadHeadlines() {
    setState(() {
      _headlinesFuture = _fetchSelectedCountryNews();
    });
  }

  void _onCountryChanged(NewsCountry? country) {
    if (country == null) {
      return;
    }

    setState(() {
      _selectedCountry = country;
      _headlinesFuture = _fetchSelectedCountryNews();
    });
  }

  Future<void> _refresh() async {
    final future = _fetchSelectedCountryNews();
    setState(() {
      _headlinesFuture = future;
    });

    try {
      await future;
    } catch (_) {
      return;
    }
  }

  Future<List<Article>> _fetchSelectedCountryNews() {
    return _service.fetchCountryNews(
      countryCode: _selectedCountry.code,
      countryName: _selectedCountry.name,
      useTopHeadlines: _selectedCountry.useTopHeadlines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SearchScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<_HomeMenuAction>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry<_HomeMenuAction>>[
                PopupMenuItem<_HomeMenuAction>(
                  value: _HomeMenuAction.about,
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('About'),
                  ),
                ),
                PopupMenuItem<_HomeMenuAction>(
                  value: _HomeMenuAction.exit,
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Exit'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: DropdownButtonFormField<NewsCountry>(
              initialValue: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
              items: _countries
                  .map((NewsCountry country) {
                    return DropdownMenuItem<NewsCountry>(
                      value: country,
                      child: Text(country.name),
                    );
                  })
                  .toList(growable: false),
              onChanged: _onCountryChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _headlinesFuture,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Article>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _StateMessage(
                        icon: Icons.wifi_off,
                        title: 'Could not load headlines',
                        message: apiErrorMessage(snapshot.error),
                        buttonLabel: 'Retry',
                        onPressed: _loadHeadlines,
                      );
                    }

                    if (!snapshot.hasData) {
                      return _StateMessage(
                        icon: Icons.article_outlined,
                        title: 'No data received',
                        message: 'The server did not return any articles.',
                        buttonLabel: 'Retry',
                        onPressed: _loadHeadlines,
                      );
                    }

                    final articles = snapshot.data!;
                    if (articles.isEmpty) {
                      return _StateMessage(
                        icon: Icons.article_outlined,
                        title: 'No headlines here',
                        message: 'Try another country or refresh the list.',
                        buttonLabel: 'Retry',
                        onPressed: _loadHeadlines,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: articles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ArticleTile(article: articles[index]);
                        },
                      ),
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(_HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.about:
        _showAboutDialog();
        break;
      case _HomeMenuAction.exit:
        SystemNavigator.pop();
        break;
    }
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Daily News'),
          content: Text(
            'Daily News is a Flutter news reader app for top headlines and article search.\n\n'
            'Developed by AAU students group project.\n\n'
            'Name: Tariku\n'
            'Date: Apr 26, 2026',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

enum _HomeMenuAction { about, exit }

class NewsCountry {
  final String name;
  final String code;
  final bool useTopHeadlines;

  const NewsCountry({
    required this.name,
    required this.code,
    this.useTopHeadlines = true,
  });
}

const List<NewsCountry> _countries = <NewsCountry>[
  NewsCountry(name: 'United States', code: 'us'),
  NewsCountry(name: 'United Kingdom', code: 'gb'),
  NewsCountry(name: 'Canada', code: 'ca'),
  NewsCountry(name: 'Australia', code: 'au'),
  NewsCountry(name: 'India', code: 'in'),
  NewsCountry(name: 'Ethiopia', code: 'et', useTopHeadlines: false),
  NewsCountry(name: 'Germany', code: 'de'),
  NewsCountry(name: 'France', code: 'fr'),
  NewsCountry(name: 'Japan', code: 'jp'),
  NewsCountry(name: 'South Africa', code: 'za'),
  NewsCountry(name: 'Nigeria', code: 'ng'),
  NewsCountry(name: 'Egypt', code: 'eg'),
  NewsCountry(name: 'United Arab Emirates', code: 'ae'),
  NewsCountry(name: 'Saudi Arabia', code: 'sa'),
  NewsCountry(name: 'Brazil', code: 'br'),
];

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
