# Daily News

## Track

Track B - News Reader App with NewsAPI.

## About The App

Daily News is a simple Flutter news app for the networking assignment. The home page shows news from the selected country. It first tries top headlines, then searches by country name if NewsAPI returns nothing. There is also a search page where I can search news by keyword. When an article is opened, the app shows the title, description, source, author, date, image, and a button to open the full article.

## How To Run

1. Create a free API key from `https://newsapi.org`.
2. Make a `.env` file in the main project folder.
3. Put the key inside it like this:

```env
NEWS_API_KEY=your_actual_newsapi_key
```

4. Install the packages:

```bash
flutter pub get
```

5. Run the app:

```bash
flutter run
```

The `.env` file is ignored by git, so the API key is not uploaded to GitHub.

## API Endpoints

- `GET https://newsapi.org/v2/top-headlines?country={cc}&apiKey={key}&pageSize=20`
- `GET https://newsapi.org/v2/everything?q={query}&apiKey={key}&pageSize=20&sortBy=publishedAt`

## Known Problems

- NewsAPI does not send the full article body, so I used a button to open the original article link.
- Ethiopia is loaded by country name search because NewsAPI does not support it in the top-headlines country list.
- The app needs a valid API key in `.env` before it can load real news.
