import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yatra_flow/localization/app_language.dart';
import 'package:yatra_flow/main.dart';
import 'package:yatra_flow/models/profile_data.dart';
import 'package:yatra_flow/screens/home_screen.dart';
import 'package:yatra_flow/widgets/auth_background.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguage.setLanguage('English');
  });

  testWidgets(
    'profile menu opens profile and edit save/cancel persists the right data',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(
            language: 'English',
            phoneNumber: '9876543210',
            countryCode: '+91',
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('home-menu')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('menu-profile')));
      await tester.pumpAndSettle();

      expect(find.text('My profile'), findsOneWidget);
      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.textContaining('YF102849'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile-edit')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('profile-full-name')),
        'Cancelled Name',
      );
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-cancel')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.tap(find.byKey(const Key('profile-cancel')));
      await tester.pumpAndSettle();
      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Cancelled Name'), findsNothing);

      await tester.tap(find.byKey(const Key('profile-edit')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('profile-full-name')),
        'Riya Mehta',
      );
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-city-dropdown')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.tap(find.byKey(const Key('profile-city-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jaipur, India').last);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-language-dropdown')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.tap(find.byKey(const Key('profile-language-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-travel-style-dropdown')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.tap(find.byKey(const Key('profile-travel-style-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spiritual').last);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-emergency-contact-name')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.enterText(
        find.byKey(const Key('profile-emergency-contact-name')),
        'Amit Kumar',
      );
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-emergency-contact-phone')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.enterText(
        find.byKey(const Key('profile-emergency-contact-phone')),
        '+91 98765 50000',
      );

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-notifications-toggle')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const Key('profile-notifications-toggle')),
            )
            .value,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('profile-notifications-toggle')));
      await tester.pump();

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-privacy-settings')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.ensureVisible(
        find.byKey(const Key('profile-privacy-settings')),
      );
      await tester.tap(find.byKey(const Key('profile-privacy-settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('privacy-public-toggle')));
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('profile-save')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      await tester.tap(find.byKey(const Key('profile-save')));
      await tester.pumpAndSettle();
      expect(find.text('Riya Mehta'), findsOneWidget);
      expect(find.text('Jaipur, India'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spiritual'), findsOneWidget);
      expect(find.text('Amit Kumar · +91 98765 50000'), findsOneWidget);
      final savedProfile = await ProfileStorage.load(
        fallbackPhoneNumber: '+91 98765 43210',
      );
      expect(savedProfile.emergencyContactName, 'Amit Kumar');
      expect(savedProfile.emergencyContactPhone, '+91 98765 50000');
      expect(savedProfile.isProfilePublic, isFalse);

      await tester.tap(find.byKey(const Key('profile-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-menu')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('menu-profile')));
      await tester.pumpAndSettle();
      expect(find.text('Riya Mehta'), findsOneWidget);
      expect(find.text('Jaipur, India'), findsOneWidget);
      expect(find.text('Amit Kumar · +91 98765 50000'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile-edit')));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.byKey(const Key('profile-notifications-toggle')),
        find.byType(ListView),
        const Offset(0, -350),
      );
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const Key('profile-notifications-toggle')),
            )
            .value,
        isFalse,
      );
    },
  );

  testWidgets('profile language change localizes home and persists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ValueListenableBuilder<String>(
        valueListenable: AppLanguage.language,
        builder: (context, language, _) => MaterialApp(
          home: HomeScreen(
            language: language,
            phoneNumber: '9876543210',
            countryCode: '+91',
          ),
        ),
      ),
    );
    expect(find.text('Search destinations, tourist places...'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('menu-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-edit')));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.byKey(const Key('profile-language-dropdown')),
      find.byType(ListView),
      const Offset(0, -350),
    );
    await tester.tap(find.byKey(const Key('profile-language-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hindi').last);
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.byKey(const Key('profile-save')),
      find.byType(ListView),
      const Offset(0, -350),
    );
    await tester.tap(find.byKey(const Key('profile-save')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('मेरी प्रोफ़ाइल'), findsOneWidget);
    expect(find.text('व्यक्तिगत जानकारी'), findsOneWidget);
    expect(find.text('आपातकालीन संपर्क'), findsOneWidget);
    final savedProfile = await ProfileStorage.load(
      fallbackPhoneNumber: '+91 98765 43210',
    );
    expect(savedProfile.language, 'Hindi');
    await AppLanguage.load();
    expect(AppLanguage.current, 'Hindi');

    await tester.tap(find.byKey(const Key('profile-back')));
    await tester.pumpAndSettle();
    expect(find.text('मंज़िलें और पर्यटन स्थल खोजें...'), findsOneWidget);
    expect(find.text('मेन्यू'), findsNothing);

    await tester.tap(find.byKey(const Key('report-problem-card')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('समस्या की रिपोर्ट करें'), findsOneWidget);
    expect(find.text('स्वच्छता'), findsOneWidget);
    await tester.tap(find.byKey(const Key('category-Cleanliness')));
    await tester.tap(find.byKey(const Key('report-continue-review')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('अपनी रिपोर्ट की समीक्षा करें'), findsOneWidget);
    expect(find.text('स्वच्छता'), findsOneWidget);
    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('रिपोर्ट सबमिट हो गई!'), findsOneWidget);
    await tester.tap(find.byKey(const Key('report-back-home')));
    await tester.pumpAndSettle();
    expect(find.text('मंज़िलें और पर्यटन स्थल खोजें...'), findsOneWidget);
  });

  testWidgets(
    'report flow validates, reviews selected data, and returns home',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen(language: 'English')),
      );
      await tester.tap(find.byKey(const Key('report-problem-card')));
      await tester.pumpAndSettle();
      expect(find.text('Report a Problem'), findsOneWidget);

      await tester.tap(find.byKey(const Key('report-continue-review')));
      await tester.pump();
      expect(
        find.text('Please select a problem category to continue.'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.byKey(const Key('category-Parking')));
      await tester.tap(find.byKey(const Key('category-Parking')));
      await tester.ensureVisible(find.byKey(const Key('report-description')));
      await tester.enterText(
        find.byKey(const Key('report-description')),
        'The parking area is blocked.',
      );
      await tester.tap(find.byKey(const Key('report-continue-review')));
      await tester.pumpAndSettle();

      expect(find.text('Review Your Report'), findsOneWidget);
      expect(find.text('Parking'), findsOneWidget);
      expect(find.text('The parking area is blocked.'), findsOneWidget);
      expect(find.text('Not provided'), findsOneWidget);

      await tester.tap(find.byKey(const Key('report-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Report Submitted!'), findsOneWidget);
      expect(
        tester.widget<SelectableText>(find.byKey(const Key('report-id'))).data,
        matches(RegExp(r'^RPT-\d{4}-\d{6}$')),
      );

      await tester.tap(find.byKey(const Key('report-back-home')));
      await tester.pumpAndSettle();
      expect(
        find.text('Search destinations, tourist places...'),
        findsOneWidget,
      );
    },
  );

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
    await tester.tap(find.text('ठीक है'));
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
