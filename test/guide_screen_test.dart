import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yatra_flow/screens/home_screen.dart';

void main() {
  testWidgets('home Guide tab opens updates and every update has a detail page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(language: 'English')),
    );

    await tester.tap(find.byKey(const Key('home-tab-1')));
    await tester.pumpAndSettle();

    expect(find.text('Latest Updates & Alerts'), findsOneWidget);
    expect(find.byKey(const Key('guide-notifications-filter')), findsOneWidget);

    const updateTitles = <String, String>{
      'rainfall': 'Heavy Rainfall Alert',
      'bhajan-sandhya': 'Bhajan Sandhya',
      'facilities': 'New Facilities at Bhawan',
      'helpline': 'Helpline Update',
    };

    for (final entry in updateTitles.entries) {
      await tester.tap(find.byKey(Key('guide-update-${entry.key}')));
      await tester.pumpAndSettle();

      expect(find.text('Alert Details'), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('Recommended precautions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('guide-detail-back')));
      await tester.pumpAndSettle();
    }
  });
}
