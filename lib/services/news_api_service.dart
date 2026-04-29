import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/article.dart';
import 'api_exception.dart';

class NewsApiService {
  final String _baseUrl = 'newsapi.org';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = const <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  final http.Client _client;

  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Article>> fetchCountryNews({
    required String countryCode,
    required String countryName,
    bool useTopHeadlines = true,
  }) async {
    if (!useTopHeadlines) {
      return searchArticles(countryName);
    }

    final headlines = await fetchTopHeadlines(countryCode);
    if (headlines.isNotEmpty) {
      return headlines;
    }

    return searchArticles(countryName);
  }

  Future<List<Article>> fetchTopHeadlines(String countryCode) async {
    final apiKey = _apiKey;
    _ensureApiKey(apiKey);

    final uri = Uri.https(_baseUrl, '/v2/top-headlines', <String, String>{
      'country': countryCode,
      'apiKey': apiKey,
      'pageSize': '20',
    });

    final response = await _client
        .get(uri, headers: _headers)
        .timeout(_timeout);
    _checkResponse(response);
    return _parseArticles(response.body);
  }

  Future<List<Article>> searchTopHeadlines({
    required String query,
    required String countryCode,
    int pageSize = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return <Article>[];
    }

    final apiKey = _apiKey;
    _ensureApiKey(apiKey);

    final uri = Uri.https(_baseUrl, '/v2/top-headlines', <String, String>{
      'q': trimmedQuery,
      'country': countryCode,
      'apiKey': apiKey,
      'pageSize': pageSize.toString(),
    });

    final response = await _client
        .get(uri, headers: _headers)
        .timeout(_timeout);
    _checkResponse(response);
    return _parseArticles(response.body);
  }

  Future<List<Article>> searchArticles(
    String query, {
    int pageSize = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return <Article>[];
    }

    final apiKey = _apiKey;
    _ensureApiKey(apiKey);

    final uri = Uri.https(_baseUrl, '/v2/everything', <String, String>{
      'q': trimmedQuery,
      'apiKey': apiKey,
      'pageSize': pageSize.toString(),
      'sortBy': 'publishedAt',
    });

    final response = await _client
        .get(uri, headers: _headers)
        .timeout(_timeout);
    _checkResponse(response);
    return _parseArticles(response.body);
  }

  String get _apiKey => dotenv.env['NEWS_API_KEY']?.trim() ?? '';

  void _ensureApiKey(String apiKey) {
    if (apiKey.isEmpty) {
      throw const ApiException(
        statusCode: 0,
        message: 'Missing NEWS_API_KEY. Add it to the .env file.',
      );
    }
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode == 200) {
      return;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(response),
    );
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['message'] as String? ??
          response.reasonPhrase ??
          'Request failed';
    } on FormatException {
      return response.reasonPhrase ?? 'Request failed';
    } on TypeError {
      return response.reasonPhrase ?? 'Request failed';
    }
  }

  List<Article> _parseArticles(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final articlesJson = decoded['articles'] as List<dynamic>? ?? <dynamic>[];

      return articlesJson
          .map((dynamic item) => Article.fromJson(item as Map<String, dynamic>))
          .where((Article article) => article.url.isNotEmpty)
          .toList(growable: false);
    } on FormatException {
      rethrow;
    } on TypeError catch (error) {
      throw FormatException('Unexpected NewsAPI response shape: $error');
    }
  }
}
