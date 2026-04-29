import 'package:flutter/material.dart';

import '../models/article.dart';
import 'detail_screen.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final String? searchQuery;
  final String? countryName;

  const ArticleTile({
    super.key,
    required this.article,
    this.searchQuery,
    this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return ArticleDetailScreen(article: article);
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ArticleImage(imageUrl: article.urlToImage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _QueryText(
                      text: article.title,
                      query: searchQuery,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _QueryText(
                      text: _visibleText,
                      query: searchQuery,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _metadataText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _visibleText {
    final query = searchQuery?.trim();
    final texts = <String>[
      if (article.description != null) article.description!,
      if (article.content != null) article.content!,
    ];

    if (query == null || query.isEmpty) {
      return texts.firstWhere(
        (String text) => text.trim().isNotEmpty,
        orElse: () => 'No description available.',
      );
    }

    for (final text in texts) {
      final excerpt = _excerptAroundQuery(text, query);
      if (excerpt != null) {
        return excerpt;
      }
    }

    return texts.firstWhere(
      (String text) => text.trim().isNotEmpty,
      orElse: () => 'No description available.',
    );
  }

  String get _metadataText {
    final parts = <String>[
      if (countryName != null && countryName!.trim().isNotEmpty)
        countryName!.trim(),
      article.sourceName,
      _formatDate(article.publishedAt),
    ];
    return parts.join(' · ');
  }

  String? _excerptAroundQuery(String text, String query) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return null;
    }

    final lowerText = cleanText.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    if (index == -1) {
      return null;
    }

    final start = (index - 48).clamp(0, cleanText.length);
    final end = (index + query.length + 96).clamp(0, cleanText.length);
    final prefix = start > 0 ? '... ' : '';
    final suffix = end < cleanText.length ? ' ...' : '';
    return '$prefix${cleanText.substring(start, end).trim()}$suffix';
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Date unavailable';
    }

    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _QueryText extends StatelessWidget {
  final String text;
  final String? query;
  final int maxLines;
  final TextStyle? style;

  const _QueryText({
    required this.text,
    required this.query,
    required this.maxLines,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query?.trim();
    if (trimmedQuery == null || trimmedQuery.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final spans = <TextSpan>[];
    var index = 0;

    while (index < text.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, index);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(index)));
        break;
      }

      if (matchIndex > index) {
        spans.add(TextSpan(text: text.substring(index, matchIndex)));
      }

      final matchEnd = matchIndex + trimmedQuery.length;
      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchEnd),
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      index = matchEnd;
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ArticleImage extends StatelessWidget {
  final String? imageUrl;

  const _ArticleImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 88,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _ImagePlaceholder(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return _ImagePlaceholder(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Color color;

  const _ImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Icon(
        Icons.newspaper,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
