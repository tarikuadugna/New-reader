import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_api/main.dart';

void main() {
  testWidgets('renders the news reader shell', (WidgetTester tester) async {
    await tester.pumpWidget(const NewsApp());

    expect(find.text('Top Headlines'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
  });
}
