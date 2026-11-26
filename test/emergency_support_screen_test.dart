import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yatra_flow/localization/app_language.dart';
import 'package:yatra_flow/screens/emergency_support_screen.dart';
import 'package:yatra_flow/screens/home_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguage.setLanguage('English');
  });

  testWidgets('home emergency card opens the support flow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(language: 'English')),
    );

    await tester.tap(find.byKey(const Key('emergency-support-card')));
    await tester.pumpAndSettle();

    expect(find.text('Emergency & Support'), findsOneWidget);
    expect(find.byKey(const Key('emergency-demo-notice')), findsOneWidget);
  });

  testWidgets('SOS requires confirmation and only creates a demo status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EmergencySupportScreen()));

    await tester.tap(find.byKey(const Key('emergency-sos')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm SOS'), findsOneWidget);

    await tester.tap(find.byKey(const Key('emergency-sos-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm SOS'), findsNothing);
    expect(find.byKey(const Key('emergency-demo-notice')), findsOneWidget);

    await tester.tap(find.byKey(const Key('emergency-sos')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('emergency-sos-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Emergency Alert Demo'), findsOneWidget);
    expect(find.text('Not sent (demo)'), findsOneWidget);
    expect(find.text('Not shared'), findsOneWidget);
    final contactText = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data?.startsWith('Configured contact:') == true,
      ),
    );
    expect(contactText.data, 'Configured contact: +91 8709453483');
    expect(find.byKey(const Key('emergency-demo-request-id')), findsOneWidget);
  });

  testWidgets('non-urgent report opens with demo-only notice', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EmergencySupportScreen()));

    await tester.tap(find.byKey(const Key('emergency-nonurgent-report')));
    await tester.pumpAndSettle();

    expect(find.text('Report a Problem'), findsOneWidget);
    expect(find.byKey(const Key('report-demo-notice')), findsOneWidget);

    await tester.tap(find.text('Cleanliness'));
    await tester.tap(find.byKey(const Key('report-continue-review')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-demo-notice')), findsOneWidget);

    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Demo Report Created'), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byKey(const Key('report-id'))).data,
      matches(RegExp(r'^DEMO-RPT-\d{4}-\d{6}$')),
    );
  });
}
