import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yatra_flow/localization/app_language.dart';
import 'package:yatra_flow/screens/home_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguage.setLanguage('English');
  });

  testWidgets('Near Places opens Explore with working crowd filters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(language: 'English')),
    );

    await tester.tap(find.byKey(const Key('near-places-card')));
    await tester.pumpAndSettle();

    expect(find.text('Explore Jaipur'), findsOneWidget);
    expect(find.byKey(const Key('place-card-amber-fort')), findsOneWidget);
    expect(find.byKey(const Key('place-card-hawa-mahal')), findsOneWidget);
    expect(find.byKey(const Key('place-card-city-palace')), findsOneWidget);

    await tester.tap(find.byKey(const Key('explore-filter-quiet')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('place-card-jantar-mantar')), findsOneWidget);
    expect(find.byKey(const Key('place-card-jal-mahal')), findsOneWidget);
    expect(find.byKey(const Key('place-card-hawa-mahal')), findsNothing);

    await tester.tap(find.byKey(const Key('explore-filter-near')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('place-card-albert-hall')), findsOneWidget);
    expect(find.byKey(const Key('place-card-nahargarh-fort')), findsOneWidget);
    expect(find.byKey(const Key('place-card-jaigarh-fort')), findsOneWidget);
  });

  testWidgets('Home search opens Explore and filters after submission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(language: 'English')),
    );

    await tester.tap(find.byKey(const Key('home-search')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('explore-search')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('explore-search')),
      'Hawa Mahal',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-card-hawa-mahal')), findsOneWidget);
    expect(find.byKey(const Key('place-card-amber-fort')), findsNothing);
  });
}
