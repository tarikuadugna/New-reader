class Article {
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String sourceName;
  final String? author;
  final DateTime? publishedAt;

  const Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.sourceName,
    required this.author,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final source =
        json['source'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final publishedAtText = json['publishedAt'] as String?;

    return Article(
      title: json['title'] as String? ?? 'Untitled article',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      sourceName: source['name'] as String? ?? 'Unknown source',
      author: json['author'] as String?,
      publishedAt: _parseDate(publishedAtText),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'sourceName': sourceName,
      'author': author,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  Article copyWith({
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? sourceName,
    String? author,
    DateTime? publishedAt,
  }) {
    return Article(
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      sourceName: sourceName ?? this.sourceName,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
