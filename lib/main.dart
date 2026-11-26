import 'package:material_ui/material_ui.dart';

import 'localization/app_language.dart';
import 'screens/mobile_number_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLanguage.load();
  runApp(const YatraFlowApp());
}

class YatraFlowApp extends StatelessWidget {
  const YatraFlowApp({super.key});

  static const _purple = Color(0xFF6650B6);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.language,
      builder: (context, language, _) => MaterialApp(
        title: 'YatraFlow',
        locale: Locale(language == 'Hindi' ? 'hi' : 'en'),
        supportedLocales: const [Locale('en'), Locale('hi')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _purple,
            primary: _purple,
            surface: const Color(0xFFF8F9FD),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FD),
          fontFamily: 'Roboto',
        ),
        home: const MobileNumberScreen(),
      ),
    );
  }
}
