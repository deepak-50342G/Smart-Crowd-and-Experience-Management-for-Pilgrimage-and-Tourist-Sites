import 'package:material_ui/material_ui.dart';

import '../localization/app_language.dart';
import 'guide_screen.dart';
import 'profile_screens.dart';

const _safetyPurple = Color(0xFF563B98);
const _safetyInk = Color(0xFF302A43);
const _safetyMuted = Color(0xFF6B6578);
const _safetyCanvas = Color(0xFFF7F5FB);

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({
    this.phoneNumber = '',
    this.countryCode = '+91',
    super.key,
  });

  final String phoneNumber;
  final String countryCode;

  static const _tips = <(String, String)>[
    (
      'Keep documents handy',
      'Carry a copy of your ID, visa and insurance. Store digital copies securely.',
    ),
    (
      'Share your plans',
      'Tell someone you trust where you are going and when you expect to return.',
    ),
    (
      'Choose trusted transport',
      'Use licensed services. Check the driver and vehicle details before getting in.',
    ),
    (
      'Protect your belongings',
      'Keep valuables out of sight and bags close. Never share PINs or one-time passwords.',
    ),
    (
      'Plan for your health',
      'Carry essential medicines and safe water. Check food hygiene and know your limits.',
    ),
    (
      'Check local conditions',
      'Follow local advice, weather alerts and signs. Avoid isolated areas, especially after dark.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _safetyCanvas,
      appBar: AppBar(
        backgroundColor: _safetyCanvas,
        foregroundColor: _safetyInk,
        title: Text(
          AppLanguage.translate('Travel safely'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
              children: [
                Text(
                  AppLanguage.translate(
                    'A few essentials to help you stay prepared, aware and confident on your journey.',
                  ),
                  style: const TextStyle(
                    color: _safetyMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguage.translate('Need urgent help?'),
                        style: const TextStyle(
                          color: _safetyInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLanguage.translate(
                          'Move to a safe place. Contact local emergency services and share your location. Save the local emergency number before you travel.',
                        ),
                        style: const TextStyle(
                          color: _safetyMuted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  AppLanguage.translate('Before you head out'),
                  style: const TextStyle(
                    color: _safetyInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                for (var index = 0; index < _tips.length; index++)
                  _SafetyTipRow(index: index + 1, title: _tips[index].$1, body: _tips[index].$2),
                const SizedBox(height: 8),
                Text(
                  AppLanguage.translate(
                    'Stay alert. Trust your instincts. Ask for help.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _safetyPurple,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _SafetyBottomNavigation(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );
  }
}

class _SafetyTipRow extends StatelessWidget {
  const _SafetyTipRow({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE7F5),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: _safetyPurple,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.translate(title),
                  style: const TextStyle(
                    color: _safetyInk,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLanguage.translate(body),
                  style: const TextStyle(
                    color: _safetyMuted,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyBottomNavigation extends StatelessWidget {
  const _SafetyBottomNavigation({
    required this.phoneNumber,
    required this.countryCode,
  });

  final String phoneNumber;
  final String countryCode;

  static const _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.chat_bubble_outline_rounded, 'Guide'),
    (Icons.verified_user_outlined, 'Safety'),
    (Icons.person_outline_rounded, 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFF0ECF3),
          border: Border(top: BorderSide(color: Color(0xFFE4E0E8))),
        ),
        child: Row(
          children: [
            for (var index = 0; index < _tabs.length; index++)
              Expanded(
                child: InkWell(
                  key: Key('safety-tab-$index'),
                  onTap: () {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else if (index == 1) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GuideScreen(
                            phoneNumber: phoneNumber,
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    } else if (index == 3) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MyProfileScreen(
                            phoneNumber: phoneNumber,
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[index].$1,
                        size: 16,
                        color: index == 2 ? _safetyPurple : _safetyMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguage.translate(_tabs[index].$2),
                        style: TextStyle(
                          fontSize: 9,
                          color: index == 2 ? _safetyPurple : _safetyMuted,
                          fontWeight: index == 2
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
