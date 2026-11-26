import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yatra_flow/main.dart';
import 'package:yatra_flow/widgets/auth_background.dart';

void main() {
  testWidgets('mobile number entry validates and continues to OTP', (
    tester,
  ) async {
    await tester.pumpWidget(const YatraFlowApp());

    expect(find.byType(AuthBackground), findsOneWidget);
    expect(find.text('YatraFlow'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.enterText(find.byKey(const Key('phone-number')), '9876543210');
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.byType(AuthBackground), findsNWidgets(2));
    expect(
      find.text('Enter the 6-digit code sent to\n+91 ******3210'),
      findsOneWidget,
    );
    expect(find.textContaining('123456'), findsOneWidget);
  });

  testWidgets('demo OTP accepts 123456 and rejects an incorrect code', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const YatraFlowApp());
    await tester.enterText(find.byKey(const Key('phone-number')), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('otp-code')), '000000');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(
      find.text('That code didn’t match. Please try again.'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('otp-code')), '123456');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.text('Select your language'), findsOneWidget);
    expect(find.text('English (default)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hindi (हिन्दी)').last);
    await tester.pumpAndSettle();
    expect(find.text('Hindi (हिन्दी)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();
    expect(find.text('मंज़िलें और पर्यटन स्थल खोजें...'), findsOneWidget);
    expect(find.text('आपातकालीन सहायता'), findsOneWidget);
    expect(find.text('पंजीकरण'), findsOneWidget);
    expect(find.text('होम'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(5));
    expect(find.byKey(const Key('home-banner')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-menu')));
    await tester.pump();
    expect(find.text('मेन्यू'), findsOneWidget);
    expect(find.text('प्रोफ़ाइल'), findsOneWidget);
    await tester.tap(find.byKey(const Key('menu-close')));
    await tester.pump();
    expect(find.text('प्रोफ़ाइल'), findsNothing);

    await tester.tap(find.byKey(const Key('chat-toggle')));
    await tester.pump();
    expect(find.text('नमस्ते! मैं आपकी क्या मदद कर सकता हूँ?'), findsOneWidget);
    expect(find.text('आप क्या जानना चाहेंगे?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat-toggle')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('register-card')));
    await tester.pumpAndSettle();
    expect(find.text('अपना पंजीकरण पूरा करें'), findsOneWidget);

    await tester.tap(find.byKey(const Key('registration-continue')));
    await tester.pump();
    expect(find.text('पहचान पत्र का प्रकार चुनें'), findsOneWidget);

    await tester.tap(find.byKey(const Key('document-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('आधार कार्ड').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('registration-id')),
      '123456789012',
    );
    await tester.enterText(
      find.byKey(const Key('registration-name')),
      'Ravi Kumar',
    );
    await tester.tap(find.byKey(const Key('registration-dob')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('registration-address')),
      'Jaipur, Rajasthan',
    );
    await tester.tap(find.byKey(const Key('registration-continue')));
    await tester.pumpAndSettle();
    expect(find.text('डेमो मोड: 123456 दर्ज करें।'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('registration-otp-code')),
      '000000',
    );
    await tester.tap(find.byKey(const Key('registration-verify-otp')));
    await tester.pump();
    expect(find.text('सही 6 अंकों का OTP 123456 दर्ज करें।'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('registration-otp-code')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('registration-verify-otp')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('registration-qr')), findsOneWidget);
    expect(find.textContaining('YATRAFLOW-'), findsOneWidget);
    expect(find.text('मुझे स्कैन करें'), findsOneWidget);

    await tester.tap(find.byKey(const Key('registration-qr-continue')));
    await tester.pumpAndSettle();
    expect(find.text('अब आप प्रवेश कर सकते हैं'), findsOneWidget);
    await tester.tap(find.byKey(const Key('registration-back-home')));
    await tester.pumpAndSettle();
    expect(find.text('मंज़िलें और पर्यटन स्थल खोजें...'), findsOneWidget);
  });

  testWidgets('invalid Indian number shows an error without navigating', (
    tester,
  ) async {
    await tester.pumpWidget(const YatraFlowApp());
    await tester.enterText(find.byKey(const Key('phone-number')), '1234567890');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(find.text('Verify your number'), findsNothing);
  });

  testWidgets('country selection updates code and number length', (
    tester,
  ) async {
    await tester.pumpWidget(const YatraFlowApp());
    await tester.tap(find.text('+91'));
    await tester.pumpAndSettle();
    expect(find.text('Select country'), findsOneWidget);
    await tester.tap(find.text('Australia'));
    await tester.pumpAndSettle();

    expect(find.text('+61'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('phone-number')), '412345678');
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
