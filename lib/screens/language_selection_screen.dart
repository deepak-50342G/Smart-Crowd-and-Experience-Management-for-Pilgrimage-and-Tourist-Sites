import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({
    required this.phoneNumber,
    required this.countryCode,
    super.key,
  });

  final String phoneNumber;
  final String countryCode;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const _languages = <String, String>{
    'English': 'English (default)',
    'Hindi': 'Hindi (हिन्दी)',
  };

  String _selectedLanguage = AppLanguage.current;

  Future<void> _continue() async {
    try {
      await AppLanguage.setLanguage(_selectedLanguage);
    } on AppLanguagePersistenceException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLanguage.text(
                'Could not save your language preference. Please try again.',
                'भाषा की प्राथमिकता सहेजी नहीं जा सकी। कृपया फिर से कोशिश करें।',
              ),
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          language: _selectedLanguage,
          phoneNumber: widget.phoneNumber,
          countryCode: widget.countryCode,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLanguage.translate('Select your language'),
                style: TextStyle(
                  color: Color(0xFF20365D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDCE2EF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const Key('language-selector'),
                    value: _selectedLanguage,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF8792A8),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF20365D),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _languages.entries
                        .map(
                          (language) => DropdownMenuItem<String>(
                            value: language.key,
                            child: Text(AppLanguage.translate(language.value)),
                          ),
                        )
                        .toList(),
                    onChanged: (language) {
                      if (language != null) {
                        setState(() => _selectedLanguage = language);
                      }
                    },
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  key: const Key('language-continue'),
                  onPressed: _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2864ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    AppLanguage.translate('Continue'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
