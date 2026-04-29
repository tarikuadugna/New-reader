import 'dart:async';

import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/news_country.dart';
import '../services/api_error_message.dart';
import '../services/news_api_service.dart';
import 'article_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final NewsApiService _service = NewsApiService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  NewsCountry _selectedCountry = newsCountries.first;
  List<Article> _articles = <Article>[];
  Object? _error;
  bool _isLoading = false;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    if (query.isEmpty) {
      _requestId++;
      setState(() {
        _articles = <Article>[];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = _selectedCountry.useTopHeadlines
          ? await _service.searchTopHeadlines(
              query: query,
              countryCode: _selectedCountry.code,
            )
          : await _service.searchArticles(
              '${query.trim()} ${_selectedCountry.name}',
            );
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _articles = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  void _retry() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }
    _debounce?.cancel();
    _search(query);
  }

  void _onCountryChanged(NewsCountry? country) {
    if (country == null) {
      return;
    }

    setState(() {
      _selectedCountry = country;
      _articles = <Article>[];
      _error = null;
    });

    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      _debounce?.cancel();
      _search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search News')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'Keyword',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onQueryChanged,
                  onSubmitted: (String value) {
                    _debounce?.cancel();
                    _search(value.trim());
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<NewsCountry>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                    border: OutlineInputBorder(),
                  ),
                  items: newsCountries
                      .map((NewsCountry country) {
                        return DropdownMenuItem<NewsCountry>(
                          value: country,
                          child: Text(country.name),
                        );
                      })
                      .toList(growable: false),
                  onChanged: _onCountryChanged,
                ),
              ],
            ),
          ),
          if (_controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Headlines for "${_controller.text.trim()}" in ${_selectedCountry.name}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _SearchStateMessage(
        icon: Icons.wifi_off,
        title: 'Search failed',
        message: apiErrorMessage(_error),
        buttonLabel: 'Retry',
        onPressed: _retry,
      );
    }

    if (_controller.text.trim().isEmpty) {
      return const _SearchStateMessage(
        icon: Icons.search,
        title: 'Search for news',
        message: 'Enter a topic to find recent articles.',
      );
    }

    if (_articles.isEmpty) {
      return _SearchStateMessage(
        icon: Icons.article_outlined,
        title: 'No articles found',
        message: 'Try another keyword.',
        buttonLabel: 'Retry',
        onPressed: _retry,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _articles.length,
      itemBuilder: (BuildContext context, int index) {
        return ArticleTile(
          article: _articles[index],
          searchQuery: _controller.text.trim(),
          countryName: _selectedCountry.name,
        );
      },
    );
  }
}

class _SearchStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const _SearchStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
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
            if (buttonLabel != null && onPressed != null) ...<Widget>[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.refresh),
                label: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
