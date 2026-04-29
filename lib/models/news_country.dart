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

const List<NewsCountry> newsCountries = <NewsCountry>[
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
