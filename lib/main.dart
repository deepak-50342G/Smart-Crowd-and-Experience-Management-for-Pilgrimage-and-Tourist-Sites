import 'package:material_ui/material_ui.dart' hide GlobalMaterialLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/mobile_number_screen.dart';

void main() {
  runApp(const YatraFlowApp());
}

class YatraFlowApp extends StatelessWidget {
  const YatraFlowApp({super.key});

  static const _purple = Color(0xFF6650B6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YatraFlow',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
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
    );
  }
}
