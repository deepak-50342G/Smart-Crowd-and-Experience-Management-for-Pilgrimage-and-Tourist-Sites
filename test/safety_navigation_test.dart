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

  testWidgets('Safety tab opens the travel safety guide', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          language: 'English',
          phoneNumber: '9876543210',
          countryCode: '+91',
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('home-tab-2')));
    await tester.pumpAndSettle();

    expect(find.text('Travel safely'), findsOneWidget);
    expect(find.text('Need urgent help?'), findsOneWidget);
    expect(find.text('Before you head out'), findsOneWidget);
    expect(find.text('Keep documents handy'), findsOneWidget);
    expect(find.text('Check local conditions'), findsOneWidget);
  });

  testWidgets('You tab opens the profile screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          language: 'English',
          phoneNumber: '9876543210',
          countryCode: '+91',
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('home-tab-3')));
    await tester.pumpAndSettle();

    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
  });
}
